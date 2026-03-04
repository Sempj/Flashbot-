# Stage 1: Build the Application
FROM node:18 AS build

WORKDIR /usr/src/app

# Copy package.json and package-lock.json first to leverage caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the app
COPY . .

# Stage 2: Create the Final Production Image
FROM node:18

WORKDIR /usr/src/app

# Copy installed modules and app from build stage
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package*.json ./
COPY --from=build /usr/src/app .

# Expose the app port
ENV PORT=8080
EXPOSE $PORT

# Run as non-root user
USER node

# Start the app
CMD ["node", "index.js"]
