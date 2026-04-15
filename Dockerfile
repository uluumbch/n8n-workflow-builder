# ---- Build stage ----
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies (including devDependencies for TypeScript compilation)
COPY package*.json ./
RUN npm ci

# Copy source and compile
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# ---- Production stage ----
FROM node:20-alpine AS production

WORKDIR /app

# Install only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy compiled output from builder
COPY --from=builder /app/build ./build

# N8N_HOST defaults to a local n8n instance; override at runtime as needed.
ENV N8N_HOST=http://localhost:5678
# N8N_API_KEY has no default – always supply it at runtime via -e or --env-file.

# Entry point matches the "bin" field in package.json (build/server.cjs).
ENTRYPOINT ["node", "build/server.cjs"]
