MYCLUSTER="$(cat ./cluster.name)"
MYENV="$(cat ./cluster.env)"
MYORG="$(cat ./cluster.org)"

read -r -d '' PART1 <<-"CONFIGEOF"
apiVersion: v1
kind: Namespace
metadata:
  name: 'allspark'
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ecr-read-only--service-account
  namespace: 'allspark'
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: asp-cluster-manager
rules:
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["endpoints", "pods", "services", "deployments"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["nodes/proxy"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps", "extensions"]
  resources: ["endpoints", "pods", "services", "deployments"]
  verbs: ["create", "get", "watch", "list", "update", "delete"]
- apiGroups: ["apps"]
  resources: ["replicasets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["*"]
- apiGroups: ["extensions"]
  resources: ["thirdpartyresources", "thirdpartyresources.extensions", "ingresses", "ingresses/status"]
  verbs: ["*"]
- apiGroups: ["extensions"]
  resources: ["virtualservices", "destinationrules", "gateways"]
  verbs: ["get", "watch", "list", "update"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: ["batch"]
  resources: ["jobs"]
  verbs: ["create", "get", "watch", "list", "update", "delete"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["create", "get", "watch", "list", "update", "delete"]
- apiGroups: [""]
  resources: ["serviceaccounts"]
  verbs: ["create", "get", "watch", "list", "update", "delete"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["rolebindings"]
  verbs: ["create"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["clusterroles"]
  verbs: ["bind"]
  resourceNames: ["admin","edit","view"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["clusterroles"]
  verbs: ["create", "get", "watch", "list", "update", "delete", "patch"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["clusterrolebindings"]
  verbs: ["create", "get", "watch", "list", "update", "delete", "patch"]
- apiGroups: ["config.istio.io"]
  resources: ["*"]
  verbs: ["create", "get", "list", "watch"]
- apiGroups: ["rbac.istio.io"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["config.istio.io"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["namespaces", "nodes"]
  verbs: ["create", "get", "list", "patch", "watch"]
- apiGroups: ["*"]
  resources: ["configmaps"]
  verbs: ["get", "list", "patch", "watch"]
- apiGroups: ["*"]
  resources: ["deployments"]
  resourceNames: ["istio-galley"]
  verbs: ["*"]
- apiGroups: ["*"]
  resources: ["deployments"]
  resourceNames: ["istio-proxy"]
  verbs: ["*"]
- apiGroups: ["*"]
  resources: ["extensions"]
  resourceNames: ["istio-pilot"]
  verbs: ["*"]
- apiGroups: ["*"]
  resources: ["endpoints"]
  resourceNames: ["istio-galley"]
  verbs: ["*"]
- apiGroups: ["admissionregistration.k8s.io"]
  resources: ["mutatingwebhookconfigurations"]
  verbs: ["get", "list", "watch", "patch", "create", "delete"]
- apiGroups: ["admissionregistration.k8s.io"]
  resources: ["validatingwebhookconfigurations"]
  verbs: ["*"]
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["config.istio.io"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["networking.istio.io"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["authentication.istio.io"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apiextensions.k8s.io"]
  resources: ["customresourcedefinitions"]
  verbs: ["create", "get", "watch", "list", "update", "delete"]
- apiGroups: ["extensions"]
  resources: ["replicasets"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["create", "get", "list", "patch",  "update", "watch"]
- apiGroups: ["allspark.vmware.com"]
  resources: ["aspclusters"]
  verbs: ["create", "get", "watch", "list", "update", "delete"]
- apiGroups: ["policy"]
  resources: ["podsecuritypolicies"]
  verbs: ["use"]
---
# Grant permissions to the k8s-cluster-manager.
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: asp-cluster-manager-admin-rb
subjects:
- kind: ServiceAccount
  name: asp-cluster-manager-svc-acnt
  namespace: 'allspark'
roleRef:
  kind: ClusterRole
  name: asp-cluster-manager
  apiGroup: rbac.authorization.k8s.io
---
# This is needed for Istio install - specifically the clusterroles in Istio
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: asp-cluster-manager-cluster-admin
subjects:
- kind: ServiceAccount
  name: asp-cluster-manager-svc-acnt
  namespace: 'allspark'
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ''
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: asp-cluster-manager-svc-acnt
  namespace: 'allspark'
---
# CRD for AllSpark clusters
apiVersion: "apiextensions.k8s.io/v1beta1"
kind: "CustomResourceDefinition"
metadata:
  name: "aspclusters.allspark.vmware.com"
  namespace: 'allspark'
spec:
  group: "allspark.vmware.com"
  version: "v1alpha1"
  scope: "Namespaced"
  names:
    plural: "aspclusters"
    singular: "aspcluster"
    kind: "AllsparkCluster"
    shortNames:
    - aspcl
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: 'k8s-cluster-manager'
  namespace: 'allspark'
data:
  .k8s-cluster-manager.yaml: |
    allspark-version: 'v0.3.0'
    disable-automatic-dns: 'false'
    manager:
      cluster:
        port: 40041
CONFIGEOF

read -r -d '' PART2 <<CONFIGEOF
        remoteaddr: "${MYENV}:443"
        exporter: grpc
        registrationservicehost: "local-registration-service"
        registrationserviceport: "30031"
        cloudconnectorport: "50051"
        cluster-name: '${MYCLUSTER}'
        organization: '${MYORG}'
CONFIGEOF

read -r -d '' PART3 <<-"CONFIGEOF"
        sync:
          k8s:
            namespaces:
              - "*" #all namespaces
            resources:
              service:
                dbresource: servicegroup
              deployment:
                dbresource: serviceinstance
              pod:
                dbresource: serviceinstance
              node:
                dbresource: node
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: 'k8s-cluster-manager'
  namespace: 'allspark'
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: 'k8s-cluster-manager'
    spec:
      imagePullSecrets:
      - name: ecr-read-only--docker-credentials
      serviceAccountName: asp-cluster-manager-svc-acnt
      containers:
      - image: 284299419820.dkr.ecr.us-west-2.amazonaws.com/k8s-cluster-manager:v0.7.1
        imagePullPolicy: Always
        name: 'k8s-cluster-manager'
        args: ["cluster"]
        ports:
        - containerPort: 40041
        volumeMounts:
        - name: config-volume
          mountPath: /home/k8smanager
      restartPolicy: Always
      volumes:
      - name: config-volume
        configMap:
          name: 'k8s-cluster-manager'
---
apiVersion: v1
kind: Service
metadata:
  name: 'k8s-cluster-manager'
  namespace: 'allspark'
  labels:
    app: 'k8s-cluster-manager'
spec:
  ports:
  - port: 40041
    targetPort: 40041
    name: grpc
  selector:
    app: 'k8s-cluster-manager'
---
apiVersion: v1
kind: Secret
metadata:
  name: ecr-read-only--aws-credentials
  namespace: 'allspark'
type: Opaque
data:
  # The secret variables need to be removed
  # See https://jira.eng.vmware.com/browse/AS-1087
  AWS_ACCESS_KEY_ID: 'QUtJQUpFREg1NERBUTRHWFcyRUE='
  AWS_SECRET_ACCESS_KEY: 'WFVUU0ptaXdYNFN1bzBYZ0kxMWFhU2thUXliZTdVYVVDSjl2Mk4yWQ=='
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ecr-read-only--role
  namespace: 'allspark'
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create", "get", "watch", "list", "update", "delete"]
- apiGroups: ["policy"]
  resources: ["podsecuritypolicies"]
  verbs: ["use"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ecr-read-only--role-binding
  namespace: 'allspark'
subjects:
- kind: ServiceAccount
  name: ecr-read-only--service-account
roleRef:
  kind: Role
  name: ecr-read-only--role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: ecr-read-only--renew-token
  namespace: 'allspark'
spec:
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  schedule: "0 */8 * * *"
  # schedule: "*/1 * * * *"
  jobTemplate:
    spec: &cronjob_spec
      template:
        metadata:
          labels:
            run: ecr-read-only--renew-token
        spec:
          serviceAccountName: ecr-read-only--service-account
          containers:
          - name: ecr-read-only--renew-token
            # Image in public repo. See ticket AS-1019
            image: vmwareallspark/ubuntu-aws-kubectl:16.04
            # imagePullPolicy: Always
            imagePullPolicy: IfNotPresent
            env:
              - name: AWS_ACCESS_KEY_ID
                valueFrom:
                  secretKeyRef:
                    name: ecr-read-only--aws-credentials
                    key: AWS_ACCESS_KEY_ID
              - name: AWS_SECRET_ACCESS_KEY
                valueFrom:
                  secretKeyRef:
                    name: ecr-read-only--aws-credentials
                    key: AWS_SECRET_ACCESS_KEY
            command:
            - "/bin/bash"
            - "-c"
            - |
              # env | grep AWS

              aws ecr get-login --no-include-email --region us-west-2 > aws.login.dt
              export DOCKER_SERVER=`cat aws.login.dt | cut -d ' ' -f 7`
              export DOCKER_USERNAME='AWS'
              export DOCKER_PASSWORD=`cat aws.login.dt | cut -d' ' -f 6`
              # env | grep DOCKER

              # Secret will be created in current namespace
              kubectl delete secret ecr-read-only--docker-credentials || true
              kubectl create secret docker-registry ecr-read-only--docker-credentials \
                --docker-server=$DOCKER_SERVER \
                --docker-username=$DOCKER_USERNAME \
                --docker-password=$DOCKER_PASSWORD \
                --docker-email=no@email.local
              # sleep 300
          restartPolicy: Never
---
apiVersion: batch/v1
kind: Job
metadata:
  name: ecr-read-only--renew-token
  namespace: 'allspark'
spec:
  # Note that a YAML anchor does NOT work across YAML document :-(
  # <<: *cronjob_spec
  backoffLimit: 4
  template:
    metadata:
      name: ecr-read-only--renew-token
    spec:
      serviceAccountName: ecr-read-only--service-account
      containers:
      - name: ecr-read-only--renew-token
        image: vmwareallspark/ubuntu-aws-kubectl:16.04
        # imagePullPolicy: Always
        imagePullPolicy: IfNotPresent
        env:
          - name: AWS_ACCESS_KEY_ID
            valueFrom:
              secretKeyRef:
                name: ecr-read-only--aws-credentials
                key: AWS_ACCESS_KEY_ID
          - name: AWS_SECRET_ACCESS_KEY
            valueFrom:
              secretKeyRef:
                name: ecr-read-only--aws-credentials
                key: AWS_SECRET_ACCESS_KEY
        command:
        - "/bin/bash"
        - "-c"
        - |
          # env | grep AWS

          aws ecr get-login --no-include-email --region us-west-2 > aws.login.dt
          export DOCKER_SERVER=`cat aws.login.dt | cut -d ' ' -f 7`
          export DOCKER_USERNAME='AWS'
          export DOCKER_PASSWORD=`cat aws.login.dt | cut -d' ' -f 6`
          # env | grep DOCKER

          # Secret will be created in current namespace
          kubectl delete secret ecr-read-only--docker-credentials || true
          kubectl create secret docker-registry ecr-read-only--docker-credentials \
            --docker-server=$DOCKER_SERVER \
            --docker-username=$DOCKER_USERNAME \
            --docker-password=$DOCKER_PASSWORD \
            --docker-email=no@email.local
          # sleep 300
      restartPolicy: Never
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: 'allspark-ws-proxy-k8s-cluster-manager'
  namespace: 'allspark'
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: 'allspark-ws-proxy-k8s-cluster-manager'
    spec:
      imagePullSecrets:
        - name: ecr-read-only--docker-credentials
      serviceAccountName: asp-cluster-manager-svc-acnt
      containers:
      - image: 284299419820.dkr.ecr.us-west-2.amazonaws.com/ws-client:v0.3.0
        imagePullPolicy: Always
        name: 'allspark-ws-proxy-k8s-cluster-manager'
        volumeMounts:
        - name: config-volume
          mountPath: /home/wsclient
      volumes:
      - name: config-volume
        configMap:
          name: 'allspark-ws-proxy-k8s-cluster-manager'
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: 'allspark-ws-proxy-k8s-cluster-manager'
  namespace: 'allspark'
data:
  .allspark-proxy.yaml: |
    allspark-version: 'v0.3.0'
    manager:
      healthserverport: 60000
      localaddr: 'k8s-cluster-manager:40041'
CONFIGEOF

read -r -d '' PART4 <<CONFIGEOF
      remoteaddr: '${MYENV}:443'
      remoteurl:  'allspark-ws-proxy-${MYORG}-${MYCLUSTER}'
      insecureskipverify: true
CONFIGEOF

MYFILE="nsx-sm_${MYCLUSTER}.yaml"
printf "%s\n" "Building file [${MYFILE}]"
printf "%s\n" "${PART1}" > ${MYFILE}
printf "        " >> ${MYFILE}
printf "%s\n" "${PART2}" >> ${MYFILE}
printf "        " >> ${MYFILE}
printf "%s\n" "${PART3}" >> ${MYFILE}
printf "      " >> ${MYFILE}
printf "%s\n" "${PART4}" >> ${MYFILE}
