local config = import '.libsonnet/config.libsonnet';

// local deploy = {
//   toHost(name, host):: {
//     local environment = config.environments[name],
//     name: name,
//     pull: 'if-not-exists',
//     image: config.images.awsCli,
//     commands: [
//       #'./deploy.sh ' + environment.name + ' ' + host,
//       'echo "hello world"',
//     ],
//     environment: environment.environment_variables,
//     when: {
//       event: ['promote'],
//       target: [name],
//     },
//   },
//   toKubernetes(name, service):: {
//     local environment = config.environments[name]
//     name: name,
//     pull: 'if-not-exists',
//     image: config.images.kubectl,
//     commands: [
//       'echo "hello world"',
//       #'TAG=$(yq r ' + environment.name + '/versions.yml regina kubernetes.$SERVICE',
//       #'if [[ "${TAG}" =~ ".*:.*" ]]; then SERVICE_TAG=${TAG}; else SERVICE_TAG=${SERVICE}:${TAG}; fi',
//       #'if [ -d kubernetes/$SERVICE/overlays/' + environment.name + ' ]; then cd kubernetes/$SERVICE/overlays/' + environment + '; else cd kubernetes/$SERVICE/base; fi',
//       #'kustomize edit set image ' + config.images.regina_base,
//       #'aws eks update-kubeconfig --name ' + config.environments[name].awsAccount,
//       #'SENTRY_RELEASE_TAG=$TAG kubectl apply -k .',
//       #'kubectl -n ' + environment + ' rollout status --timeout=15m deployment/$SERVICE',
//     ],
//     environment: config.access_keys[name],
//     when: {
//       event: ['promote'],
//       target: [name],
//     },
//   },
// };


#{
#  kind: 'pipeline',
#  type: 'kubernetes',
#  name: 'default',
#
#  steps: [
#    deploy.toHost('dev', 'dev-hft1'),
#    deploy.toHost('uat', '$INSTANCE'),
#    deploy.toHost('prod', '$INSTANCE'),
#    deploy.toKubernetes('kubedev', '${SERVICE}'),
#    deploy.toKubernetes('kubeuat', '${SERVICE}'),
#    deploy.toKubernetes('kubeprod', '${SERVICE}'),
#    deploy.toKubernetes('kubeprod-tok', '${SERVICE}'),
#    {
#      name: 'slack',
#      image: 'plugins/slack',
#      settings: {
#        webhook: {
#          from_secret: 'regina_slack_webhook',
#        },
#        channel: 'dev-hft-deploy',
#        template: |||
#          {{#success build.status}}
#              deployment {{ repo.name }} {{build.number}} succeeded to {{ build.deployTo }}. {{ build.link }}
#          {{else}}
#              deployment {{ repo.name }} {{build.number}} failed deployment to {{ build.deployTo }}. {{ build.link }}
#           {{/success}}
#        |||,
#        when: {
#          status: ['success', 'failure'],
#        },
#        event: ['promote'],
#      },
#    },
#  ],
#}

local fn = {
  build_param(name):: std.native('buildParam')(name),
};

local pipeline(title, name) = {
  kind: 'pipeline',
  type: 'kubernetes',
  name: title,
  trigger: {
    event: ['promote'],
    target: [name],
  },
  steps: [
    //local environment = config.environments[ename],
    name: 'deploy to ' + fn.build_param('INSTANCE'),
    pull: 'if-not-exists',
    image: config.images.aws_cli,
    commands: [
      'echo "hello world"',
    ],
  ],
}

[
 pipeline('deploy to dev', 'dev')
]
