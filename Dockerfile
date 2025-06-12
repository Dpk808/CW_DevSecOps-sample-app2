# Use official Node.js LTS image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install --production

# Bundle app source
COPY index.js ./

# Expose port
EXPOSE 3000

# Start the app
CMD ["node", "index.js"]

# Test 12
