# obsint-processing-ai-bot-instance

Custom bot runner built on [dev-bot](https://github.com/RedHatInsights/platform-frontend-ai-dev).

## Build

```bash
git submodule update --init --recursive
docker build -f dev-bot/Dockerfile.runner -t my-bot-instance:local .
```

## Updating dev-bot

```bash
cd dev-bot && git pull origin master && cd ..
git add dev-bot
git commit -m "chore: update dev-bot submodule"
```

Original repo: https://github.com/RedHatInsights/platform-frontend-ai-dev/tree/6d7d7a8704e987be8934a1b9713c2b03228819ed#
Ctibor's image: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/platform-frontend-ai-dev/obsint-deploy.yaml?ref_type=heads
The bot's dashboard showing off what is happening: https://devbot-memory-server-platform-frontend-ai-dev-stage.apps.rosa.hcmais01ue1.s9m2.p3.openshiftapps.com/#/instances/Ctibor%20%C5%A0%C5%A5astn%C3%BD%20z%20%C4%8Cacht%C3%ADc/tasks
Processing team skills living in: https://github.com/RedHatInsights/processing-tools/tree/master/skills
