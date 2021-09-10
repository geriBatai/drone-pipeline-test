local config = import '.libsonnet/config.libsonnet';
local build_param(name) = std.native('buildParam')(name);

local pipeline(title, name) = {
  kind: 'pipeline',
  type: 'kubernetes',
  name: title,
  trigger: {
    event: ['promote'],
    target: [name],
    requires: {
      INSTANCE: build_param('INSTANCE'),
    },
  },
  steps: [
    {
      name: 'validate parameters',
      image: config.images.aws_cli,
      commands: [
        '[ "x${INSTANCE}" == "x" ] && echo "INSTANCE param not set" && exit 1',
      ],
    },
    {
      //local environment = config.environments[ename],
      name: 'deploy to ' + build_param('INSTANCE'),
      pull: 'if-not-exists',
      image: config.images.aws_cli,
      commands: [
        'echo "hello world"',
      ],
    },
  ],
};


[
  {
    kind: 'pipeline',
    type: 'kubernetes',
    name: 'default',
  },
  pipeline('deploy to dev', 'dev'),
]
