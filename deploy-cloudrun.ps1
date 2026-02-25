$ErrorActionPreference = "Stop"

# Fill these before running:
$PROJECT_ID = "gen-lang-client-0673582886"
$REGION = "us-central1"
$REPOSITORY = "a2a-images"
$SERVICE = "a2a-healthcare"
$IMAGE = "$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$SERVICE:latest"

gcloud config set project $PROJECT_ID

gcloud services enable `
  run.googleapis.com `
  artifactregistry.googleapis.com `
  cloudbuild.googleapis.com `
  secretmanager.googleapis.com `
  aiplatform.googleapis.com

# Create Artifact Registry repo once (skip if already exists).
gcloud artifacts repositories create $REPOSITORY `
  --repository-format=docker `
  --location=$REGION `
  --description="Docker images for A2A healthcare agents" `
  2>$null

# Create secret once (skip if already exists):
# echo -n "<YOUR_GEMINI_API_KEY>" | gcloud secrets create GEMINI_API_KEY --data-file=-
# If it exists, add a new version:
# echo -n "<YOUR_GEMINI_API_KEY>" | gcloud secrets versions add GEMINI_API_KEY --data-file=-

gcloud builds submit --tag $IMAGE

gcloud run deploy $SERVICE `
  --image $IMAGE `
  --region $REGION `
  --allow-unauthenticated `
  --set-secrets GEMINI_API_KEY=GEMINI_API_KEY:latest `
  --set-env-vars AGENT_HOST=127.0.0.1,POLICY_AGENT_PORT=9999,RESEARCH_AGENT_PORT=9998,PROVIDER_AGENT_PORT=9997 `
  --cpu 2 `
  --memory 2Gi `
  --timeout 900
