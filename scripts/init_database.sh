#!/bin/sh

# Auto-initialization script for Appwrite database
# Runs once when Docker Compose starts

echo "⏳ Waiting for Appwrite to be ready..."
sleep 30

echo "🔧 Initializing database (placeholder - manual setup required via Appwrite console)"
echo "✅ Database initialization placeholder complete"
echo ""
echo "📝 Next steps:"
echo "1. Open http://localhost to access Appwrite console"
echo "2. Create project and get API keys"
echo "3. Update bot_service/.env with your credentials"
echo "4. Restart services: docker-compose restart"

exit 0
