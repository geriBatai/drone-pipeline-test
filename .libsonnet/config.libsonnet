{
  images: {
    aws_cli: '211161777205.dkr.ecr.eu-west-1.amazonaws.com/b2c2ltd/awscli:2.2.16',
    kubectl: '211161777205.dkr.ecr.eu-west-1.amazonaws.com/b2c2ltd/drone-eks-kubectl',
  },
  environments: {
    dev: {
      title: 'Deploy to dev',
    },
    uat: {
      title: 'Deploy to uat',
    },
    prod: {
      title: 'Deploy to prod',
    },
    kubedev: {
      title: 'Deploy to kubernetes dev',
      path: 'dev',
    },

  },
}
