local config = import '.libsonnet/config.libsonnet';
local build_param(name) = std.native('buildParam')(name);


local pipeline(title, name) = {
  kind: 'pipeline',
  type: 'kubernetes',
  name: title,
  trigger: {
    event: ['promote'],
    target: [name],
  },
  steps: [
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
  pipeline('deploy to dev', 'dev'),
]
