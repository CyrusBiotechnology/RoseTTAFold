local env = {
    imageName: "RoseTTAFold",
};

local buildAndPushImage() = [
    {
        name: "build Dockerfile",
        image: "gcr.io/cyrus-containers/drone-plugins/gcr:linux-amd64",
        environment: {
            ARTI_NAME: {
                from_secret: "arti_user"
            },
            ARTI_PASS: {
                from_secret: "arti_pass"
            },
            ROSETTACOMMONS_CONDA_USERNAME: {
                from_secret: "ROSETTACOMMONS_CONDA_USERNAME"
            },
            ROSETTACOMMONS_CONDA_PASSWORD: {
                from_secret: "ROSETTACOMMONS_CONDA_PASSWORD"
            }
        },
        privileged: true,
        resources: {
            requests: {
                memory: "10GB"
            },
        },
        settings: {
            registry: "gcr.io",
            repo: "cyrus-containers/" + env.imageName,
            "tags.normalize": true,
            tags: [
              $DRONE_COMMIT_BRANCH,
              $DRONE_COMMIT_BRANCH + "-" + $DRONE_COMMIT_SHA
            ]
            debug: true,
            json_key: {
                from_secret: "drone-cyrus-containers-key"
            },
            build_args_from_env: [
                "ARTI_NAME",
                "ARTI_PASS",
                "ROSETTACOMMONS_CONDA_USERNAME",
                "ROSETTACOMMONS_CONDA_PASSWORD"
            ],
        },
        when: {
            event: "push"
        },
    },
];

[
    {
        kind: "pipeline",
        name: env.imageName,
        type: "kubernetes",
        steps:  (
            buildAndPushImage()
        ),
    }
]
