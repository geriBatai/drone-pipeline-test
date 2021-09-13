local config = import '.libsonnet/config.libsonnet';
//local build_param(name) = std.native('buildParam')(name);
local build_param(name) = name;

local deploy_to_host(title, name, instance) = {
  local deploy_to = if std.isString(instance) then instance else build_param('INSTANCE'),
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
            INSTANCE: build_param('INSTANCE'),
          },
        },
      },
    ],
};


//[
{
  kind: 'pipeline',
  type: 'kubernetes',
  name: 'default',
  trigger: {
    event: {
      exclude: ['promote'],
    },
  },
}
//deploy_to_host('deploy to dev', 'dev', 'hft1'),
//deploy_to_host('deploy to uat', 'uat', null),
//]

