apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: secret-challenge
  name: secret-challenge
  namespace: default
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: secret-challenge
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: "2020-10-28T20:21:04Z"
      labels:
        app: secret-challenge
      name: secret-challenge
    spec:
      serviceAccountName: vault
      volumes:
        - name: secrets-store-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: "wrongsecrets-gcp-secretsmanager"
      containers:
        - image: jeroenwillemsen/wrongsecrets:1.1.0-k8s-vault
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
              protocol: TCP
          name: secret-challenge
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          env:
            - name: GCP_PROJECT_ID
              value: ${GCP_PROJECT}
            - name: K8S_ENV
              value: gcp
            - name: SPECIAL_K8S_SECRET
              valueFrom:
                configMapKeyRef:
                  name: secrets-file
                  key: funny.entry
            - name: SPECIAL_SPECIAL_K8S_SECRET
              valueFrom:
                secretKeyRef:
                  name: funnystuff
                  key: funnier
            - name: VAULT_ADDR
              value: "http://vault:8200"
            - name: JWT_PATH
              value: "/var/run/secrets/kubernetes.io/serviceaccount/token"
          volumeMounts:
            - name: secrets-store-inline
              mountPath: "/mnt/secrets-store"
              readOnly: true
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
