local services = [
  { name: 'service-one' },
];

local config = import '.libsonnet/config.libsonnet';
local build_param(name) = std.native('buildParam')(name);

local deploy_to_host(title, name, instance) = {
  local deploy_to = [ if instance then instance else build_param('INSTANCE') ];
  kind: 'pipeline',
  type: 'kubernetes',
  name: title,
  trigger: {
    event: ['promote'],
    target: [name],
  },
  steps: [
    {
      name: 'validate parameters',
      image: config.images.aws_cli,
      commands: [
        './validate-params.sh INSTANCE $INSTANCE',
      ],
    },
    {
      //local environment = config.environments[ename],
      name: 'deploy to ' + deploy_to,
      pull: 'if-not-exists',
      image: config.images.aws_cli,
      commands: [
        'echo "hello world"',
      ],
      when: {
        params: {
          INSTANCE: build_param('INSTANCE'),
        },
      },
    },
  ],
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
  deploy_to_host('deploy to dev', 'dev', 'hft1'),
]
