local deploy = import '.libsonnet/deploy.libsonnet';

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
  deploy.to_host('prod', null),
  deploy.to_kubernetes('kubedev'),
  deploy.to_kubernetes('kubeuat'),
  deploy.to_kubernetes('kubeprod'),
  deploy.to_kubernetes('kubeprod-tok'),
]
