# Work System AWS Config Verification Notes

## Scope

This note records what is present in `work-system-aws-config/` at verification time and highlights mismatches against externally provided inventory narratives.

## Confirmed Top-Level Service Folders

- `apigw/`
- `cloudwatch/`
- `lambdas/`
- `opensearch/`
- `waf/`

## Confirmed File Counts

- `apigw/`: 62
- `cloudwatch/`: 13
- `lambdas/`: 226
- `opensearch/`: 25
- `waf/`: 8

## Not Found in This Repository Snapshot

The following paths were not found in the checked-in repository state:

- `work-system-aws-config/aws/`
- `work-system-aws-config/aws-config.md`
- `work-system-aws-config/amazon-ecr-and-ecs-policies-and-roles.md`

## Guidance

When answering questions, use this folder's checked-in files as canonical evidence. If a user references missing deployment/config script files, request those artefacts explicitly or treat them as external, non-repo context.
