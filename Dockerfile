# --- Build Stage ---
# Use an official Node.js image as the base for building the application.
# We name this stage 'build' to be able to reference it later.
FROM node:18-alpine AS build

# Set the working directory inside the container.
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker's layer caching.
# This layer will only be rebuilt if these files change.
COPY package*.json ./

# Install all dependencies, including devDependencies, which might be needed for build or test steps.
RUN npm install

# Copy the rest of the application source code into the container.
COPY . .

# --- Production Stage ---
# Start from a fresh, minimal Node.js image for the final production container.
FROM node:18-alpine

# Set the working directory.
WORKDIR /app

# Copy only the production dependencies from the 'build' stage.
# This avoids including devDependencies in the final image, making it smaller and more secure.
COPY --from=build /app/node_modules ./node_modules

# Copy the application code from the 'build' stage.
COPY --from=build /app ./

# Expose the port the application runs on.
EXPOSE 3000

# The command to run when the container starts.
CMD ["node", "server.js"]
