# Stage 1: Build dependencies
FROM node:18-slim AS build

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Stage 2: Production image
FROM node:18-slim

WORKDIR /usr/src/app

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    g++ \
    make \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Copy dependencies and app from build stage
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY . .

# Create non-root user
RUN useradd -m -u 1000 nodejs && chown -R nodejs:nodejs /usr/src/app

# Expose app port
ENV PORT=8080
EXPOSE $PORT

# Use non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (r) => {r.statusCode === 200 ? process.exit(0) : process.exit(1)})" || exit 1

# Start the bot
CMD ["node", "bot.js"]
