local config = import '.libsonnet/config.libsonnet';
local fn = {
  build_param(name):: std.native('buildParam')(name),
};

local deploy = {
  to_host(name, instance):: {
    local deploy_to = if std.isString(instance) then instance else fn.build_param('INSTANCE'),
    local environment = config.environments[name],
    kind: 'pipeline',
    type: 'kubernetes',
    name: environment.title,
    trigger: {
      event: ['promote'],
      target: [name],
    },
    steps:
      (if std.isString(instance) then [] else [{
         name: 'validate parameters',
         image: config.images.aws_cli,
         commands: [
           './validate-params.sh INSTANCE $INSTANCE',
         ],
       }]) +
      [
        {
          name: 'deploy to ' + deploy_to,
          pull: 'if-not-exists',
          image: config.images.aws_cli,
          commands: [
            'echo "hello world"',
          ],
          [if !std.isString(instance) then 'when']: {
            params: {
              INSTANCE: fn.build_param('INSTANCE'),
            },
          },
        },
      ],
  },
  to_kubernetes(name):: {
    local environment = config.environments[name],
    local service = fn.build_param('SERVICE'),
    kind: 'pipeline',
    type: 'kubernetes',
    name: environment.title,
    trigger: {
      event: ['promote'],
      params: {
        SERVICE: fn.build_param('SERVICE'),
      },
    },
    steps: [
      {
        name: 'validate parameters',
        image: config.images.aws_cli,
        commands: [
          './validate-params.sh SERVICE $SERVICE',
        ],
      },
      {
        name: 'deploy ' + service,
        pull: 'if-not-exists',
        image: config.images.kubectl,
        commands: [
          'TAG=$(yq r ' + environment.path + '/versions.yml regina.kubernetes.$SERVICE)',
          'if [[ "${TAG}" == *":"* ]]; then SERVICE_TAG=${TAG}; else SERVICE_TAG=${SERVICE}:${TAG}; fi',
          'echo ${SERVICE_TAG}',
          //'if [ -d kubernetes/$SERVICE/overlays/' + environment.path + ' ]; then cd kubernetes/$SERVICE/overlays/' + environment.path + '; else cd kubernetes/$SERVICE/base; fi',
          //'kustomize edit set image ' + config.images.regina_base,
          //'aws eks update-kubeconfig --name ' + config.environments[name].aws_account,
          //'SENTRY_RELEASE_TAG=$TAG kubectl apply -k .',
          //'kubectl -n ' + environment + ' rollout status --timeout=15m deployment/$SERVICE',
        ],
      },
    ],

  },
};


[
  {
    kind: 'pipeline',
    type: 'kubernetes',
    name: 'default',
    trigger: {
      event: {
        exclude: ['promote'],
      },
    },
  },
  deploy.to_host('dev', 'hft1'),
  deploy.to_host('uat', null),
  deploy.to_kubernetes('kubedev'),
  //deploy.to_kubernetes('deploy to kubernetes uat', 'kubeuat', 'uat'),
  //deploy.to_kubernetes('deploy to kubernetes prod', 'kubeprod', 'prod'),
  //deploy.to_kubernetes('deploy to kubernetes prod (tokyo)', 'kubeprod-tok', 'prod'),
]
