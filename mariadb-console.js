#!/usr/bin/env node

import {spawn} from "child_process"
import fs from "fs/promises"
import yaml from "js-yaml"

const dockerComposeContent = await fs.readFile("./docker-compose.yml")
const dockerCompose = yaml.load(dockerComposeContent)
const mariadbEnvironment = dockerCompose?.services?.mariadb?.environment
const rootPassword = mariadbEnvironment?.MARIADB_ROOT_PASSWORD || mariadbEnvironment?.MYSQL_ROOT_PASSWORD
const thisDirName = process.cwd().split("/").pop()

if (!rootPassword) {
  throw new Error("Could not detect MariaDB root password from docker-compose.yml. Expected MARIADB_ROOT_PASSWORD or MYSQL_ROOT_PASSWORD.")
}

const command = `/usr/bin/mariadb -u root -p${rootPassword}`

spawn("docker", ["exec", "-it", `${thisDirName}-mariadb-1`, "/bin/bash", "-c", command], {
  stdio: "inherit"
})
