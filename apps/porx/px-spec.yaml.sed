apiVersion: v1
kind: ServiceAccount
metadata:
  name: px-account
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1alpha1
metadata:
   name: node-get-put-list-role
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["watch", "get", "update", "list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1alpha1
metadata:
  name: node-role-binding
subjects:
- kind: ServiceAccount
  name: px-account
  namespace: kube-system
  apiVersion: v1
roleRef:
  kind: ClusterRole
  name: node-get-put-list-role
  apiGroup: rbac.authorization.k8s.io

---
kind: Service
apiVersion: v1
metadata:
  name: portworx-service
  namespace: kube-system
spec:
  selector:
    name: portworx
  ports:
    - protocol: TCP
      port: 9001
      targetPort: 9001
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: portworx
  namespace: kube-system
spec:
  minReadySeconds: 0
  updateStrategy:
    type: OnDelete
  template:
    metadata:
      labels:
        name: portworx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: px/enabled
                operator: NotIn
                values:
                - "false"
              
              - key: node-role.kubernetes.io/master
                operator: DoesNotExist
              
      hostNetwork: true
      hostPID: true
      containers:
        - name: portworx
          image: portworx/px-enterprise:1.2.10
          terminationMessagePath: "/tmp/px-termination-log"
          imagePullPolicy: Always
          args:
             ["-k etcd:http://node1.example.com:@@NODEPORT@@",
              "-c mycluster",
              "",
              "",
              " -s /dev/sdb",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "-x", "kubernetes"]
          
          livenessProbe:
            periodSeconds: 30
            initialDelaySeconds: 840 # allow image pull in slow networks
            httpGet:
              host: 127.0.0.1
              path: /status
              port: 9001
          readinessProbe:
            periodSeconds: 10
            httpGet:
              host: 127.0.0.1
              path: /status
              port: 9001
          securityContext:
            privileged: true
          volumeMounts:
            - name: dockersock
              mountPath: /var/run/docker.sock
            - name: libosd
              mountPath: /var/lib/osd:shared
            - name: dev
              mountPath: /dev
            - name: etcpwx
              mountPath: /etc/pwx/
            - name: optpwx
              mountPath: /export_bin:shared
            - name: cores
              mountPath: /var/cores
            - name: kubelet
              mountPath: /var/lib/kubelet:shared
            - name: src
              mountPath: /lib/modules
            - name: dockerplugins
              mountPath: /run/docker/plugins
            - name: hostproc
              mountPath: /hostproc
      restartPolicy: Always
      
      serviceAccountName: px-account
      volumes:
        - name: libosd
          hostPath:
            path: /opt/pwx/root/var/lib/osd
        - name: dev
          hostPath:
            path: /dev
        - name: etcpwx
          hostPath:
            path: /opt/pwx/root/etc/pwx
        - name: optpwx
          hostPath:
            path: /opt/pwx/bin
        - name: cores
          hostPath:
            path: /var/cores
        - name: kubelet
          hostPath:
            path: /var/lib/kubelet
        - name: src
          hostPath:
            path: /lib/modules
        - name: dockerplugins
          hostPath:
            path: /run/docker/plugins
        - name: dockersock
          hostPath:
            path: /var/run/docker.sock
        - name: hostproc
          hostPath:
            path: /proc
