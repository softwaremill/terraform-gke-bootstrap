package test

import (
	"context"
	"encoding/base64"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/container/v1"
	appsv1 "k8s.io/api/apps/v1"
	apiv1 "k8s.io/api/core/v1"
	networkingv1 "k8s.io/api/networking/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/intstr"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/utils/pointer"
)

func createRestConfig(cluster *container.Cluster, ctx context.Context) (*rest.Config, error) {
	tokenSource, err := google.DefaultTokenSource(ctx, "https://www.googleapis.com/auth/cloud-platform")
	if err != nil {
		return nil, err
	}
	token, err := tokenSource.Token()
	if err != nil {
		return nil, err
	}

	ca, err := base64.StdEncoding.DecodeString(cluster.MasterAuth.ClusterCaCertificate)
	if err != nil {
		return nil, err
	}
	restConfig := rest.Config{
		Host:        cluster.Endpoint,
		BearerToken: token.AccessToken,
		TLSClientConfig: rest.TLSClientConfig{
			CAData: ca,
		},
	}
	return &restConfig, nil
}

func createK8sClientset(restConfig *rest.Config) (*kubernetes.Clientset, error) {
	clientSet, err := kubernetes.NewForConfig(restConfig)
	if err != nil {
		return nil, err
	}
	return clientSet, nil
}

func createTestDeployment(clientset *kubernetes.Clientset, deplName string) (*appsv1.Deployment, error) {
	delploymentClient := clientset.AppsV1().Deployments(apiv1.NamespaceDefault)
	deployment := &appsv1.Deployment{
		ObjectMeta: metav1.ObjectMeta{Name: deplName},
		Spec: appsv1.DeploymentSpec{
			Replicas: pointer.Int32(2),
			Selector: &metav1.LabelSelector{
				MatchLabels: map[string]string{
					"app": deplName,
				},
			},
			Template: apiv1.PodTemplateSpec{
				ObjectMeta: metav1.ObjectMeta{
					Labels: map[string]string{
						"app": deplName,
					},
				},
				Spec: apiv1.PodSpec{
					Tolerations: []apiv1.Toleration{
						{
							Key:   "test",
							Value: "test",
						},
					},
					Containers: []apiv1.Container{
						{
							Name:  "nginx",
							Image: "nginx",
							Ports: []apiv1.ContainerPort{
								{
									Name:          "http",
									Protocol:      apiv1.ProtocolTCP,
									ContainerPort: 80,
								},
							},
						},
					},
				},
			},
		},
	}

	result, err := delploymentClient.Create(context.TODO(), deployment, metav1.CreateOptions{})
	if err != nil {
		return nil, err
	}
	return result, nil
}

func createTestService(clientset *kubernetes.Clientset, serviceName string, deplName string) (*apiv1.Service, error) {
	serviceClient := clientset.CoreV1().Services(apiv1.NamespaceDefault)
	service := &apiv1.Service{
		ObjectMeta: metav1.ObjectMeta{Name: serviceName},
		Spec: apiv1.ServiceSpec{
			Selector: map[string]string{
				"app": deplName,
			},
			Ports: []apiv1.ServicePort{
				{
					Name: "http",
					TargetPort: intstr.IntOrString{
						Type:   intstr.Int,
						IntVal: 80,
					},
					Port: 80,
				},
			},
		},
	}

	result, err := serviceClient.Create(context.TODO(), service, metav1.CreateOptions{})
	if err != nil {
		return nil, err
	}
	return result, nil
}

func createTestIngress(clientset *kubernetes.Clientset, ingressName string, servicName string) (*networkingv1.Ingress, error) {
	ingressClient := clientset.NetworkingV1().Ingresses(apiv1.NamespaceDefault)
	pathType := networkingv1.PathTypePrefix
	ingress := &networkingv1.Ingress{
		ObjectMeta: metav1.ObjectMeta{Name: ingressName},
		Spec: networkingv1.IngressSpec{
			Rules: []networkingv1.IngressRule{
				{
					IngressRuleValue: networkingv1.IngressRuleValue{
						HTTP: &networkingv1.HTTPIngressRuleValue{
							Paths: []networkingv1.HTTPIngressPath{
								{
									Path:     "/",
									PathType: &pathType,
									Backend: networkingv1.IngressBackend{
										Service: &networkingv1.IngressServiceBackend{
											Name: servicName,
											Port: networkingv1.ServiceBackendPort{
												Number: 80,
											},
										},
									},
								},
							},
						},
					},
				},
			},
		},
	}

	result, err := ingressClient.Create(context.TODO(), ingress, metav1.CreateOptions{})

	if err != nil {
		return nil, err
	}
	return result, nil
}

func deleteIngress(t *testing.T, clientset *kubernetes.Clientset, ingressName string) error {
	ingressClient := clientset.NetworkingV1().Ingresses(apiv1.NamespaceDefault)
	logger.Log(t, "Deleting ingress: %s", ingressName)
	ctx := context.TODO()
	if err := ingressClient.Delete(ctx, ingressName, metav1.DeleteOptions{}); err != nil {
		logger.Logf(t, "Failed to delete ingress: %s", ingressName)
	}
	for {
		_, err := clientset.NetworkingV1().Ingresses(apiv1.NamespaceDefault).Get(ctx, ingressName, metav1.GetOptions{})
		if err != nil {
			if errors.IsNotFound(err) {
				logger.Logf(t, "Ingress %s has been deleted.\n", ingressName)
				break
			}
			return err
		}

		// Wait for a while before checking again
		logger.Logf(t, "Waiting for Ingress %s to be deleted...\n", ingressName)
		time.Sleep(10 * time.Second)
	}
	// Give some time for the ingress to be fully deleted (NEGs are deleted asynchronously)
	time.Sleep(150 * time.Second)

	return nil
}

func testExample(t *testing.T, exampleDir string) {
	randId := strings.ToLower(random.UniqueId())
	deplName := "nginx-" + randId
	serviceName := deplName
	ingressName := deplName

	platformName := "test-platform-" + randId

	terraformOptions := terraform.WithDefaultRetryableErrors(
		t,
		&terraform.Options{
			TerraformDir: exampleDir,
			Vars: map[string]interface{}{
				"platform_name": platformName,
			},
		},
	)

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	ctx := context.Background()
	containerService, _ := container.NewService(ctx)

	cluster, err := container.NewProjectsLocationsClustersService(containerService).Get(terraform.Output(t, terraformOptions, "gke_cluster_id")).Do()
	assert.NoError(t, err)

	restConfig, err := createRestConfig(cluster, ctx)
	assert.NoError(t, err)

	k8sClientSet, err := createK8sClientset(restConfig)
	assert.NoError(t, err)

	deployment, err := createTestDeployment(k8sClientSet, deplName)
	assert.NoError(t, err)

	service, err := createTestService(k8sClientSet, serviceName, deplName)
	assert.NoError(t, err)

	// Remove ingress to avoid existing NEG after cluster deletion
	defer func() {
		err := deleteIngress(t, k8sClientSet, ingressName)
		if err != nil {
			t.Errorf("Failed to delete ingress: %s, error: %s", ingressName, err.Error())
		}
	}()
	ingress, err := createTestIngress(k8sClientSet, ingressName, serviceName)
	assert.NoError(t, err)

	kubectlOptions := k8s.NewKubectlOptionsWithRestConfig(restConfig, apiv1.NamespaceDefault)

	k8s.WaitUntilDeploymentAvailable(t, kubectlOptions, deployment.Name, 20, 10*time.Second)
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, service.Name, 10, 10*time.Second)
	k8s.WaitUntilIngressAvailable(t, kubectlOptions, ingress.Name, 30, 10*time.Second)
}
