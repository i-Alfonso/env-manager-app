final List<Map<String, dynamic>> turnOffActions = [
  {
    "action": "turn-off",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "stopped",
      // instance id from response from turn-off action
      "resource_id": "id",
      "attempts": 10,
      "timeout": 15,
    },
  },
  {
    "action": "snapshot-root",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "completed",
      // snapshot id (id) from response from snapshot-root action
      "resource_id": "id",
      "attempts": 5,
      "timeout": 15,
    },
  },
  {
    "action": "snapshot-data",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "completed",
      // snapshot id (id) from response from snapshot-data action
      "resource_id": "id",
      "attempts": 5,
      "timeout": 15,
    },
  },
  {
    "action": "detach-root",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "available",
      // volume_id (id) from response from instances-status action
      "resource_id": "volume_id",
      "attempts": 5,
      "timeout": 10,
    },
  },
  {
    "action": "detach-data",
    "attempts": 3,
    "timeout": 10,
    "pass_condition": {
      "action": "resource-status",
      "response_value": "available",
      // volume_id (id) from response from instances-status action
      "resource_id": "volume_id",
      "attempts": 5,
      "timeout": 10,
    },
  },
];