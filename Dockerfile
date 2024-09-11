# Base image with Node.js
FROM node:18.17.0-alpine AS base

# Set up environment variables for pnpm
ENV PNPM_HOME="/var/lib/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Enable corepack and install pnpm globally
RUN corepack enable

# Install pnpm globally
RUN pnpm add -g pnpm

# Builder stage
FROM base AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy only package.json and pnpm-lock.yaml for dependency installation
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the Next.js application
RUN pnpm run build

# Runner stage
FROM base AS runner

# Set the working directory inside the container
WORKDIR /app

# Copy the built application from the builder stage
COPY --from=builder /app/.next /app/.next
COPY --from=builder /app/public /app/public
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json

# Expose the port the app runs on
EXPOSE 3000

# Start the Next.js application
CMD ["node_modules/.bin/next", "start"]