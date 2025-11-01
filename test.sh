BASE="https://hodlxxi.com"

REG_JSON=$(curl -s -H 'Content-Type: application/json' \
  -d '{"redirect_uris":["http://localhost:3000/callback"]}' \
  "$BASE/oauth/register")

echo "$REG_JSON" | jq .

CID=$(jq -r '.client_id'     <<<"$REG_JSON")
CSEC=$(jq -r '.client_secret'<<<"$REG_JSON")
REDIR="http://localhost:3000/callback"
SCOPE="read_limited"
STATE="xyz123"

AUTH_HEADERS_FILE=$(mktemp)
AUTH_BODY_FILE=$(mktemp)

curl -s -D "$AUTH_HEADERS_FILE" -o "$AUTH_BODY_FILE" -G "$BASE/oauth/authorize" \
  --data-urlencode client_id="$CID" \
  --data-urlencode redirect_uri="$REDIR" \
  --data-urlencode response_type="code" \
  --data-urlencode scope="$SCOPE" \
  --data-urlencode state="$STATE" \
  || true

CODE=$(sed -n 's#^location: .*code=\([^&[:space:]]*\).*#\1#Ip' "$AUTH_HEADERS_FILE" | tail -n1)
echo "CODE=$CODE"

TOK_JSON=$(curl -s -H 'Content-Type: application/x-www-form-urlencoded' \
  -d "grant_type=authorization_code&client_id=$CID&client_secret=$CSEC&code=$CODE&redirect_uri=$REDIR" \
  "$BASE/oauth/token")

echo "$TOK_JSON" | jq .

AT=$(jq -r '.access_token' <<<"$TOK_JSON")
echo "ACCESS_TOKEN=$AT"

curl -s -H "Authorization: Bearer $AT" "$BASE/api/demo/free" | jq .