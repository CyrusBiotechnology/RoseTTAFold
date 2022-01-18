local env = {
    imageName: "RoseTTAFold",
    version: "1.0.0"
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
            debug: true,
            json_key: {
                from_secret: "drone-cyrus-containers-key"
            },
            build_args: [
                "VERSION=" + env.version
            ],
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
    {
        name: "build (tag): Dockerfile",
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
            debug: true,
            json_key: {
                from_secret: "drone-cyrus-containers-key"
            },
            build_args: [
                "VERSION=" + env.version
            ],
            build_args_from_env: [
                "ARTI_NAME",
                "ARTI_PASS",
                "ROSETTACOMMONS_CONDA_USERNAME",
                "ROSETTACOMMONS_CONDA_PASSWORD"
            ],
        },
        when: {
            event: "tag"
        },
    },
];

local getVersionTag() = [
    {
        name: "Get version (feature)",
        image: "ubuntu:latest",
        commands: [
            "echo " + env.version + "-$(echo $(echo $DRONE_BRANCH | tr / -)-$DRONE_BUILD_NUMBER) > .tags",
            "echo $(cat .tags)"
        ],
        when: {
            branch: {
                exclude: "master"
            },
            event: "push"
        }
    },
    {
        name: "Get version (master)",
        image: "ubuntu:latest",
        commands: [
            "echo " + env.version + " > .tags",
            "echo $(cat .tags)"
        ],
        when: {
            branch: "master",
            event: "push"
        }
    }
];


local buildStages() = (
    buildAndPushImage()
);

[
    {
        kind: "pipeline",
        name: env.imageName,
        type: "kubernetes",
        steps:  (
            getVersionTag() +
            buildStages()
        ),
    }
]
