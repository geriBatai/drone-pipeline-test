local config = import '.libsonnet/config.libsonnet';
local fn = {
  build_param(name):: std.native('buildParam')(name),
  parse_yaml(filename):: std.native('parseYaml')(name),
};

//local build_param(name) = name;

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
  to_kubernetes(title, name, path):: {
    local service = fn.build_param('SERVICE'),
    local versions = fn.parse_yaml(path + '/versions.yml')
    local version = versions.regina.kubernetes[service],
    kind: 'pipeline',
    type: 'kubernetes',
    name: title,
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
        commands: [],
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
  deploy.to_kubernetes('deploy to kubernetes dev', 'kubedev', 'dev'),
  deploy.to_kubernetes('deploy to kubernetes uat', 'kubeuat', 'uat'),
  deploy.to_kubernetes('deploy to kubernetes prod', 'kubeprod', 'prod'),
  deploy.to_kubernetes('deploy to kubernetes prod (tokyo)', 'kubeprod-tok', 'prod'),
]
