local config = import '.libsonnet/config.libsonnet';
local fn = {
  build_param(name):: std.native('buildParam')(name),
  parse_yaml(filename):: std.native('parseYaml')(filename),
};

local deploy = {
  to_host(title, name, instance):: {
    local deploy_to = if std.isString(instance) then instance else fn.build_param('INSTANCE'),
    kind: 'pipeline',
    type: 'kubernetes',
    name: title,
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
  to_kubernetes(name, path):: {
    local environment = config[name],
    local service = fn.build_param('SERVICE'),
    local versions = fn.parse_yaml(environment.path + '/versions.yml'),
    local version = if std.isString(versions.regina.kubernetes[service] else '',
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
        name: 'deploy ' + service + ' (' + version + ')',
        pull: 'if-not-exists',
        image: config.images.kubectl,
        commands: [
          'TAG=$(yq r ' + environment.name + '/versions.yml regina kubernetes.$SERVICE',
          'if [[ "${TAG}" =~ ".*:.*" ]]; then SERVICE_TAG=${TAG}; else SERVICE_TAG=${SERVICE}:${TAG}; fi',
          'echo ${SERVICE_TAG}',
          //'if [ -d kubernetes/$SERVICE/overlays/' + environment.name + ' ]; then cd kubernetes/$SERVICE/overlays/' + environment + '; else cd kubernetes/$SERVICE/base; fi',
          //'kustomize edit set image ' + config.images.regina_base,
          //'aws eks update-kubeconfig --name ' + config.environments[name].awsAccount,
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
  deploy.to_host('deploy to dev', 'dev', 'hft1'),
  deploy.to_host('deploy to uat', 'uat', null),
  deploy.to_kubernetes('kubedev', 'dev'),
  //deploy.to_kubernetes('deploy to kubernetes uat', 'kubeuat', 'uat'),
  //deploy.to_kubernetes('deploy to kubernetes prod', 'kubeprod', 'prod'),
  //deploy.to_kubernetes('deploy to kubernetes prod (tokyo)', 'kubeprod-tok', 'prod'),
]
