___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Monitoring Pixel / Elevar Monitoring",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "debugMode",
    "displayName": "Debug Mode Variable",
    "simpleValueType": true,
    "defaultValue": "{{Debug Mode}}"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const addEventCallback = require("addEventCallback");
const copyFromWindow = require("copyFromWindow");
const setInWindow = require("setInWindow");
const sendPixel = require("sendPixel");
const encodeUri = require("encodeUri");

/**
 * This is required even though it wouldn't be used here
 * because the tests fail without it.
 */
const log = require("logToConsole");

const VALIDATION_ERRORS = "elevar_gtm_errors";
const TAG_INFO = "elevar_gtm_tag_info";
const DATA_LAYER = "dataLayer";

const onlyUnique = (arr) => {
  if (!arr) return [];
  return arr.filter((item, pos) => arr.indexOf(item) == pos);
};

const getEventName = (eventId, dataLayer) => {
  return dataLayer.reduce((item, curr) => {
    if (!item && curr["gtm.uniqueEventId"] === eventId) {
      return curr.event;
    }
    return item;
  }, false);
};

const getTagWithVariable = (tags, eventId, variableName) => {
  if (!tags) return [];
  return tags
    .filter(tag => tag.eventId === eventId)
    .filter(
      tag =>
        tag.variables &&
        tag.variables.length &&
        tag.variables.indexOf(variableName) !== -1
    );
};

const getChannels = (tags) => {
  if (!tags) return [];
  const channels = tags.map(tag => tag.channel);
  return onlyUnique(channels).join(",");
};

const getTagNames = (tags) => {
  if (!tags) return [];
  return tags
    .map(tag => tag.tagName)
    .join(",");
};

// Fires after all tags for the trigger have completed
addEventCallback(function(containerId, _eventData) {
  const dataLayer = copyFromWindow(DATA_LAYER);
  const errors = copyFromWindow(VALIDATION_ERRORS);
  const tagInfo = copyFromWindow(TAG_INFO);

  // This removes the data from window after they have been read
  setInWindow(VALIDATION_ERRORS, [], true);
  setInWindow(TAG_INFO, [], true);

  // Send Pixel if there are errors
  if (errors && errors.length > 0) {
    errors.forEach((errorEvent, index) => {
      const eventName = getEventName(errorEvent.eventId, dataLayer);
      const tagsUsed = getTagWithVariable(
        tagInfo,
        errorEvent.eventId,
        errorEvent.variableName
      );
      const channels = getChannels(tagsUsed);
      const tagNames = getTagNames(tagsUsed);

      let url = encodeUri(
        "https://monitoring.getelevar.com/track.gif?ctid=" +
          containerId +
          "&idx=" +
          index +
          "&event_name=" +
          eventName +
          "&variable_name=" +
          errorEvent.variableName +
          "&channels=" +
          channels +
          "&tag_names=" +
          tagNames +
          "&error=" +
          errorEvent.error.message +
          "&dlKey=" +
          errorEvent.dataLayerKey +
          "&dlValue=" +
          errorEvent.error.value +
          "&cond=" +
          errorEvent.error.condition +
          "&condValue=" +
          errorEvent.error.conditionValue
      );

      log("pixel url = ", url);
      if (!data.debugMode) {
        sendPixel(url);
      }
    });
  }
});

data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "elevar_gtm_errors"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "dataLayer"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "elevar_gtm_tag_info"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_metadata",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_pixel",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://monitoring.getelevar.com/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: TEST UTIL // getQueryParams
  code: |-
    assertThat(
      getQueryParams(
        'https://test.com/test_url?param=value&event_name=test_event',
        'event_name'
      )
    ).isEqualTo('test_event');

    assertThat(
      getQueryParams(
        'https://test.com/test_url?param=value&event_name=test_event',
        'param'
      )
    ).isEqualTo('value');

    assertThat(
      getQueryParams(
        'https://test.com/test_url?param=value&event_name=test_event',
        'not_real'
      )
    ).isEqualTo(undefined);
- name: PIXEL // Multiple Errors and Tag data
  code: |-
    // Call runCode to run the template's code.
    runCode(mockData);

    assertApi('copyFromWindow').wasCalled();
    assertThat(sentUrls.length === 3).isTrue();

    // -----------------------------------------------------------------

    assertThat(getQueryParams(sentUrls[0], 'ctid')).isEqualTo('containerId');
    assertThat(getQueryParams(sentUrls[0], 'idx')).isEqualTo('0');
    assertThat(getQueryParams(sentUrls[0], 'event_name')).isEqualTo('gtm.js');
    assertThat(getQueryParams(sentUrls[0], 'variable_name')).isEqualTo('dlv%20-%20Variable%201');
    assertThat(getQueryParams(sentUrls[0], 'channels')).isEqualTo('facebook');
    assertThat(getQueryParams(sentUrls[0], 'tag_names')).isEqualTo('Facebook%20-%20Initiate%20Checkout');
    assertThat(getQueryParams(sentUrls[0], 'error')).isEqualTo('message1');
    assertThat(getQueryParams(sentUrls[0], 'dlKey')).isEqualTo('key1');
    assertThat(getQueryParams(sentUrls[0], 'dlValue')).isEqualTo('val1');
    assertThat(getQueryParams(sentUrls[0], 'cond')).isEqualTo('condition1');
    assertThat(getQueryParams(sentUrls[0], 'condValue')).isEqualTo('conditionValue1');

    // -----------------------------------------------------------------

    assertThat(getQueryParams(sentUrls[1], 'ctid')).isEqualTo('containerId');
    assertThat(getQueryParams(sentUrls[1], 'idx')).isEqualTo('1');
    assertThat(getQueryParams(sentUrls[1], 'channels')).isEqualTo('');
    assertThat(getQueryParams(sentUrls[1], 'event_name')).isEqualTo('gtm.load');
    assertThat(getQueryParams(sentUrls[1], 'variable_name')).isEqualTo('dlv%20-%20Variable%202');
    assertThat(getQueryParams(sentUrls[1], 'tag_names')).isEqualTo('Facebook%20-%20Add%20To%20Cart');
    assertThat(getQueryParams(sentUrls[1], 'error')).isEqualTo('message2');
    assertThat(getQueryParams(sentUrls[1], 'dlKey')).isEqualTo('key2');
    assertThat(getQueryParams(sentUrls[1], 'dlValue')).isEqualTo('val2');
    assertThat(getQueryParams(sentUrls[1], 'cond')).isEqualTo('condition2');
    assertThat(getQueryParams(sentUrls[1], 'condValue')).isEqualTo('conditionValue2');

    // -----------------------------------------------------------------

    assertThat(getQueryParams(sentUrls[2], 'ctid')).isEqualTo('containerId');
    assertThat(getQueryParams(sentUrls[2], 'idx')).isEqualTo('2');
    assertThat(getQueryParams(sentUrls[2], 'channels')).isEqualTo('');
    assertThat(getQueryParams(sentUrls[2], 'event_name')).isEqualTo('gtm.load');
    assertThat(getQueryParams(sentUrls[2], 'variable_name')).isEqualTo('dlv%20-%20Variable%203');
    assertThat(getQueryParams(sentUrls[2], 'tag_names')).isEqualTo('');
    assertThat(getQueryParams(sentUrls[2], 'error')).isEqualTo('message3');
    assertThat(getQueryParams(sentUrls[2], 'dlKey')).isEqualTo('key3');
    assertThat(getQueryParams(sentUrls[2], 'dlValue')).isEqualTo('val3');
    assertThat(getQueryParams(sentUrls[2], 'cond')).isEqualTo('condition3');
    assertThat(getQueryParams(sentUrls[2], 'condValue')).isEqualTo('conditionValue3');
- name: PIXEL // No errors
  code: |-
    elevar_gtm_errors = undefined;

    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertApi('sendPixel').wasNotCalled();
    assertThat(sentUrls.length === 0).isTrue();
- name: PIXEL // No tags data match
  code: |-
    elevar_gtm_errors = [{
      eventId: 4,
      dataLayerKey: 'key',
      variableName: 'dlv - Variable 1',
      error: {
        message: 'message',
        value: 'val',
        condition: 'condition',
        conditionValue: 'conditionValue'
      }
    }];

    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertThat(sentUrls.length === 1).isTrue();
    assertThat(getQueryParams(sentUrls[0], 'tag_names')).isEqualTo('');
    assertThat(getQueryParams(sentUrls[0], 'channels')).isEqualTo('');
    assertThat(getQueryParams(sentUrls[0], 'variable_name')).isEqualTo('dlv%20-%20Variable%201');
- name: PIXEL // Erroring variable in multiple tags
  code: "elevar_gtm_errors = [{\n  eventId: 7,\n  dataLayerKey: 'key',\n  variableName:\
    \ 'dlv - Variable 1',\n  error: {\n    message: 'message',\n    value: 'val',\n\
    \    condition: 'condition',\n    conditionValue: 'conditionValue'\n  }\n}];\n\
    \nelevar_gtm_tag_info = [{\n\teventId: 7,\n  \tchannel: 'facebook',\n\ttagName:\
    \ \"Facebook - Initiate Checkout\",\n  \tvariables: ['dlv - Variable 1', 'dlv\
    \ - Variable 2'],\n}, {\n\teventId: 7,\n    channel: 'facebook',\n  \ttagName:\
    \ \"Facebook - Conversion\",\n   \tvariables: ['dlv - Variable 1', 'dlv - Variable\
    \ 2'],\n}];\n\n// Call runCode to run the template's code.\nrunCode(mockData);\n\
    \nassertApi('gtmOnSuccess').wasCalled();\nassertThat(getQueryParams(sentUrls[0],\
    \ 'channels')).isEqualTo('facebook');\nassertThat(\n  getQueryParams(sentUrls[0],\
    \ 'tag_names')\n).isEqualTo('Facebook%20-%20Initiate%20Checkout,Facebook%20-%20Conversion');\n\
    assertThat(sentUrls.length === 1).isTrue();"
- name: PIXEL // Missing variable name from error
  code: "elevar_gtm_errors = [{\n  eventId: 7,\n  dataLayerKey: 'key',\n  variableName:\
    \ '',\n  error: {\n    message: 'message',\n    value: 'val',\n    condition:\
    \ 'condition',\n    conditionValue: 'conditionValue'\n  }\n}];\n\nelevar_gtm_tag_info\
    \ = [{\n\teventId: 7,\n\ttagName: \"Facebook - Initiate Checkout\",\n  \tvariables:\
    \ ['dlv - Variable 1', 'dlv - Variable 2'],\n}, {\n\teventId: 7,\n  \ttagName:\
    \ \"Facebook - Conversion\",\n   \tvariables: ['dlv - Variable 1', 'dlv - Variable\
    \ 2'],\n}];\n\n// Call runCode to run the template's code.\nrunCode(mockData);\n\
    \nassertApi('gtmOnSuccess').wasCalled();\nassertThat(getQueryParams(sentUrls[0],\
    \ 'tag_names')).isEqualTo('');\nassertThat(getQueryParams(sentUrls[0], 'variable_name')).isEqualTo('');\n\
    assertThat(getQueryParams(sentUrls[0], 'error')).isEqualTo('message');\nassertThat(getQueryParams(sentUrls[0],\
    \ 'dlKey')).isEqualTo('key');\nassertThat(getQueryParams(sentUrls[0], 'dlValue')).isEqualTo('val');\n\
    assertThat(getQueryParams(sentUrls[0], 'cond')).isEqualTo('condition');\nassertThat(getQueryParams(sentUrls[0],\
    \ 'condValue')).isEqualTo('conditionValue');\nassertThat(sentUrls.length === 1).isTrue();"
- name: PIXEL // No tag info in window
  code: |-
    elevar_gtm_errors = [{
      eventId: 7,
      dataLayerKey: 'key',
      variableName: 'variable name',
      error: {
        message: 'message',
        value: 'val',
        condition: 'condition',
        conditionValue: 'conditionValue'
      }
    }];

    elevar_gtm_tag_info = undefined;

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertThat(sentUrls.length === 1).isTrue();
    assertThat(getQueryParams(sentUrls[0], 'tag_names')).isEqualTo('');
    assertThat(getQueryParams(sentUrls[0], 'variable_name')).isEqualTo('variable%20name');
    assertThat(getQueryParams(sentUrls[0], 'error')).isEqualTo('message');
    assertThat(getQueryParams(sentUrls[0], 'dlKey')).isEqualTo('key');
    assertThat(getQueryParams(sentUrls[0], 'dlValue')).isEqualTo('val');
    assertThat(getQueryParams(sentUrls[0], 'cond')).isEqualTo('condition');
    assertThat(getQueryParams(sentUrls[0], 'condValue')).isEqualTo('conditionValue');
- name: GENERAL // Debug mode
  code: |-
    mockData.debugMode = true;

    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertApi('sendPixel').wasNotCalled();
    assertThat(sentUrls.length === 0).isTrue();
setup: |
  const log = require("logToConsole");

  const sentUrls = [];

  let mockData = {
    customDataLayer: false,
    dataLayerName: "dataLayer",
    debugMode: false
  };

  let dataLayer = [
    {
      event: "gtm.dom",
      "gtm.uniqueEventId": 3
    },
    {
      "gtm.start": 1578412516211,
      event: "gtm.js",
      "gtm.uniqueEventId": 4
    },
    {
      "gtm.start": 1578412516344,
      event: "gtm.js",
      "gtm.uniqueEventId": 7
    },
    {
      event: "gtm.load",
      "gtm.uniqueEventId": 11
    }
  ];

  let elevar_gtm_errors = [
    {
      eventId: 7,
      dataLayerKey: "key1",
      variableName: "dlv - Variable 1",
      error: {
        message: "message1",
        value: "val1",
        condition: "condition1",
        conditionValue: "conditionValue1"
      }
    },
    {
      eventId: 11,
      dataLayerKey: "key2",
      variableName: "dlv - Variable 2",
      error: {
        message: "message2",
        value: "val2",
        condition: "condition2",
        conditionValue: "conditionValue2"
      }
    },
    {
      eventId: 11,
      dataLayerKey: "key3",
      variableName: "dlv - Variable 3",
      error: {
        message: "message3",
        value: "val3",
        condition: "condition3",
        conditionValue: "conditionValue3"
      }
    }
  ];

  let elevar_gtm_tag_info = [
    {
      eventId: 7,
      channel: "facebook",
      tagName: "Facebook - Initiate Checkout",
      variables: ["dlv - Variable 1", "dlv - Variable 2"]
    },
    {
      eventId: 11,
      tagName: "Facebook - Add To Cart",
      variables: ["dlv - Variable 2"]
    }
  ];

  mock("copyFromWindow", variableName => {
    switch (variableName) {
      case "elevar_gtm_errors":
        return elevar_gtm_errors;
      case "elevar_gtm_tag_info":
        return elevar_gtm_tag_info;
      case mockData.dataLayerName:
        return dataLayer;
      default:
        log("no object in mock window for variableName: ", variableName);
    }
  });

  mock("addEventCallback", callback => {
    callback("containerId");
  });

  mock("sendPixel", url => {
    sentUrls.push(url);
  });

  /* ------------ TEST UTILITY FUNCTIONS ------------ */

  const getQueryParams = (url, key) => {
    const param = url
      .split("?")[1]
      .split("&")
      .map(paramString => {
        const keyAndVal = paramString.split("=");
        return { key: keyAndVal[0], val: keyAndVal[1] };
      })
      .filter(param => param.key === key)[0];
    if (!param) return undefined;
    return param.val;
  };


___NOTES___

Created on 04/12/2019, 13:17:50


