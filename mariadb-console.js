#!/usr/bin/env node

import {spawn} from "child_process"
import fs from "fs/promises"
import yaml from "js-yaml"

const dockerComposeContent = await fs.readFile("./docker-compose.yml")
const dockerCompose = yaml.load(dockerComposeContent)
const rootPassword = dockerCompose.services.mariadb.environment.MYSQL_ROOT_PASSWORD
const thisDirName = process.cwd().split("/").pop()
const command = `/usr/bin/mariadb -u root -p${rootPassword}`

spawn("docker", ["exec", "-it", `${thisDirName}-mariadb-1`, "/bin/bash", "-c", command], {
  stdio: "inherit"
})
