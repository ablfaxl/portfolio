# Runner stage
FROM base AS runner

# Set the working directory inside the container
WORKDIR /app

# Add user for running the app
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Change ownership of the /app directory to the nextjs user
RUN chown -R nextjs:nodejs /app

# Switch to the nextjs user
USER nextjs

# Copy the built application from the builder stage
COPY --from=builder /app/.next /app/.next
COPY --from=builder /app/public /app/public
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json

# Expose the port the app runs on
EXPOSE 3000

# Start the Next.js application
CMD ["node_modules/.bin/next", "start"]