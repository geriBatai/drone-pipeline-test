{
  images: {
    aws_cli: '211161777205.dkr.ecr.eu-west-1.amazonaws.com/b2c2ltd/awscli:2.2.16',
    kubectl: '211161777205.dkr.ecr.eu-west-1.amazonaws.com/b2c2ltd/drone-eks-kubectl',
  },
  environments: {
    local environments = self,
    dev: {
      title: 'Deploy to dev',
      env_vars: {
        AWS_ACCESS_KEY_ID: {
          from_secret: 'nonprod_aws_access_key_id',
        },
        AWS_SECRET_ACCESS_KEY: {
          from_secret: 'nonprod_aws_secret_access_key',
        },
      },
    },
    uat: {
      title: 'Deploy to uat',
      env_vars: environments.dev.env_vars,
    },
    prod: {
      title: 'Deploy to prod',
      env_vars: {
        AWS_ACCESS_KEY_ID: {
          from_secret: 'prod_aws_access_key_id',
        },
        AWS_SECRET_ACCESS_KEY: {
          from_secret: 'prod_aws_secret_access_key',
        },
      },
    },
    kubedev: {
      title: 'Deploy to kubernetes dev',
      path: 'dev',
      env_vars: environments.dev.env_vars {
        AWS_DEFAULT_REGION: 'eu-west-1',
      },
    },
    kubeuat: {
      title: 'Deploy to kubernetes uat',
      path: 'dev',
      env_vars: environments.dev.env_vars {
        AWS_DEFAULT_REGION: 'eu-west-1',
      },
    },
    kubeprod: {
      title: 'Deploy to kubernetes prod',
      path: 'dev',
      env_vars: environments.dev.env_vars {
        AWS_DEFAULT_REGION: 'eu-west-1',
      },
    },
    'kubeprod-tok': {
      title: 'Deploy to kubernetes prod (Tokyo)',
      path: 'dev',
      env_vars: environments.dev.env_vars {
        AWS_DEFAULT_REGION: 'ap-northeast-1',
      },
    },
  },
}
