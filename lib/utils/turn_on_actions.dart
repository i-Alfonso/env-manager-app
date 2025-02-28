final List<Map<String, dynamic>> turnOnActions = [
  {
    "action": "create-volroot",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "available",
      // volume id from response from the create-volroot action
      "resource_id": "VolumeId",
      "attempts": 3,
      "timeout": 20,
    },
  },
  {
    "action": "create-voldata",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "available",
      // volume id from response from the create-voldata action
      "resource_id": "VolumeId",
      "attempts": 3,
      "timeout": 20,
    },
  },
  {
    "action": "atach-volroot",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "in-use",
      // volume id from response from the atach-volroot action
      "resource_id": "volume_id",
      "attempts": 3,
      "timeout": 20,
    },
  },
  {
    "action": "atach-voldata",
    "instance": "runner",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "in-use",
      // volume id from response from the atach-voldata action
      "resource_id": "volume_id",
      "attempts": 3,
      "timeout": 20,
    },
  },
  {
    "action": "turn-on",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "running",
      // instance id from response from turn-on action
      "resource_id": "id",
      "attempts": 3,
      "timeout": 20,
    },
  },
];
