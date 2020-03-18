___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Elevar - Monitoring Template",
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
    "type": "RADIO",
    "name": "customDataLayer",
    "displayName": "Is DataLayer object called \"dataLayer\"?",
    "radioItems": [
      {
        "value": true,
        "displayValue": "Yes"
      },
      {
        "value": false,
        "displayValue": "No"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "dataLayerName",
    "displayName": "Data Layer Object Name",
    "simpleValueType": true,
    "help": "The window data layer object name. By default it is \"dataLayer\".",
    "defaultValue": "dataLayer",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "customDataLayer",
        "paramValue": false,
        "type": "EQUALS"
      }
    ]
  },
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
const encodeUriComponent = require("encodeUriComponent");
const encodeUri = require("encodeUri");

/**
 * This is required even though its not used here
 * because the tests fail without it.
*/
const log = require('logToConsole');

const VALIDATION_ERRORS = "elevar_gtm_errors";
const TAG_INFO = "elevar_gtm_tag_info";

const getEventName = (eventId, dataLayer) => {
  return dataLayer.reduce((item, curr) => {
    if (!item && curr["gtm.uniqueEventId"] === eventId) {
      return curr.event;
    }
    return item;
  }, false);
};

const getTagNames = (tagInfo, eventId, variableName) =>
	tagInfo
      .filter(tag => tag.eventId === eventId)
  	  .filter(tag => tag.variables && tag.variables.length && tag.variables.indexOf(variableName) !== -1)
	  .map(tag => tag.tagName)
	  .join(',');


// Fires after all tags for the trigger have completed
addEventCallback(function(containerId, eventData) {
  const DATA_LAYER = copyFromWindow(data.dataLayerName ? data.dataLayerName : "dataLayer");
  const errors = copyFromWindow(VALIDATION_ERRORS);
  const tagInfo = copyFromWindow(TAG_INFO);

  // This removes the data from window after they have been read
  setInWindow(VALIDATION_ERRORS, [], true);
  setInWindow(TAG_INFO, [], true);

  // Send Pixel if there are errors
  if (errors && errors.length > 0) {
    errors.forEach((errorEvent, index) => {
      const eventName = getEventName(errorEvent.eventId, DATA_LAYER);
      const tagNames = getTagNames(tagInfo, errorEvent.eventId, errorEvent.variableName);

      let url = encodeUri(
          "https://monitoring.getelevar.com/track.gif?ctid=" +
          containerId +
          "&idx=" +
          index +
          "&event_name=" +
          eventName +
          "&variable_name=" +
          errorEvent.variableName +
          "&tag_names=" +
          tagNames +
          "&error=" +
          errorEvent.error.message
      );
      
      log('pixel url = ', url);
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
            "string": "all"
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
    assertThat(getQueryParams(sentUrls[0], 'tag_names')).isEqualTo('Facebook%20-%20Initiate%20Checkout');
    assertThat(getQueryParams(sentUrls[0], 'error')).isEqualTo('message1');

    // -----------------------------------------------------------------

    assertThat(getQueryParams(sentUrls[1], 'ctid')).isEqualTo('containerId');
    assertThat(getQueryParams(sentUrls[1], 'idx')).isEqualTo('1');
    assertThat(getQueryParams(sentUrls[1], 'event_name')).isEqualTo('gtm.load');
    assertThat(getQueryParams(sentUrls[1], 'variable_name')).isEqualTo('dlv%20-%20Variable%202');
    assertThat(getQueryParams(sentUrls[1], 'tag_names')).isEqualTo('Facebook%20-%20Add%20To%20Cart');
    assertThat(getQueryParams(sentUrls[1], 'error')).isEqualTo('message2');

    // -----------------------------------------------------------------

    assertThat(getQueryParams(sentUrls[2], 'ctid')).isEqualTo('containerId');
    assertThat(getQueryParams(sentUrls[2], 'idx')).isEqualTo('2');
    assertThat(getQueryParams(sentUrls[2], 'event_name')).isEqualTo('gtm.load');
    assertThat(getQueryParams(sentUrls[2], 'variable_name')).isEqualTo('dlv%20-%20Variable%203');
    assertThat(getQueryParams(sentUrls[2], 'tag_names')).isEqualTo('');
    assertThat(getQueryParams(sentUrls[2], 'error')).isEqualTo('message3');
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
    assertThat(getQueryParams(sentUrls[0], 'variable_name')).isEqualTo('dlv%20-%20Variable%201');
- name: PIXEL // Erroring variable in multiple tags
  code: "elevar_gtm_errors = [{\n  eventId: 7,\n  dataLayerKey: 'key',\n  variableName:\
    \ 'dlv - Variable 1',\n  error: {\n    message: 'message',\n    value: 'val',\n\
    \    condition: 'condition',\n    conditionValue: 'conditionValue'\n  }\n}];\n\
    \nelevar_gtm_tag_info = [{\n\teventId: 7,\n\ttagName: \"Facebook - Initiate Checkout\"\
    ,\n  \tvariables: ['dlv - Variable 1', 'dlv - Variable 2'],\n}, {\n\teventId:\
    \ 7,\n  \ttagName: \"Facebook - Conversion\",\n   \tvariables: ['dlv - Variable\
    \ 1', 'dlv - Variable 2'],\n}];\n\n// Call runCode to run the template's code.\n\
    runCode(mockData);\n\nassertApi('gtmOnSuccess').wasCalled();\nassertThat(\n  getQueryParams(sentUrls[0],\
    \ 'tag_names')\n).isEqualTo('Facebook%20-%20Initiate%20Checkout,Facebook%20-%20Conversion');\n\
    assertThat(sentUrls.length === 1).isTrue();"
- name: GENERAL // Debug mode
  code: |-
    mockData.debugMode = true;

    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertApi('sendPixel').wasNotCalled();
    assertThat(sentUrls.length === 0).isTrue();
setup: "const log = require('logToConsole');\n\nconst sentUrls = [];\n\nlet mockData\
  \ = {\n  customDataLayer: false,\n  dataLayerName: 'dataLayer',\n  debugMode: false\n\
  };\n\nlet dataLayer = [\n  {\n    \"event\":\"gtm.dom\",\n    \"gtm.uniqueEventId\"\
  :3\n  },\n  {\n    \"gtm.start\":1578412516211,\n    \"event\":\"gtm.js\",\n   \
  \ \"gtm.uniqueEventId\":4\n  },\n  {\n    \"gtm.start\":1578412516344,\n    \"event\"\
  :\"gtm.js\",\n    \"gtm.uniqueEventId\":7\n  },\n  {\n    \"event\":\"gtm.load\"\
  ,\n    \"gtm.uniqueEventId\":11\n  }\n];\n\nlet elevar_gtm_errors = [{\n  eventId:\
  \ 7,\n  dataLayerKey: 'key',\n  variableName: 'dlv - Variable 1',\n  error: {\n\
  \    message: 'message1',\n    value: 'val',\n    condition: 'condition',\n    conditionValue:\
  \ 'conditionValue'\n  }\n}, {\n  eventId: 11,\n  dataLayerKey: 'key',\n  variableName:\
  \ 'dlv - Variable 2',\n  error: {\n    message: 'message2',\n    value: 'val',\n\
  \    condition: 'condition',\n    conditionValue: 'conditionValue'\n  }}, {\n  eventId:\
  \ 11,\n  dataLayerKey: 'key',\n  variableName: 'dlv - Variable 3',\n  error: {\n\
  \    message: 'message3',\n    value: 'val',\n    condition: 'condition',\n    conditionValue:\
  \ 'conditionValue'\n  }}];\n\nlet elevar_gtm_tag_info = [{\n\teventId: 7,\n\ttagName:\
  \ \"Facebook - Initiate Checkout\",\n  \tvariables: ['dlv - Variable 1', 'dlv -\
  \ Variable 2'],\n}, {\n\teventId: 11,\n  \ttagName: \"Facebook - Add To Cart\",\n\
  \  \tvariables: ['dlv - Variable 2']\n}];\n\nmock('copyFromWindow', (variableName)\
  \ => {\n\tswitch(variableName) {\n      case 'elevar_gtm_errors':\n        return\
  \ elevar_gtm_errors;\n      case 'elevar_gtm_tag_info':\n        return elevar_gtm_tag_info;\n\
  \      case mockData.dataLayerName:\n        return dataLayer;\n      default:\n\
  \        log('no object in mock window for variableName: ', variableName);\n   \
  \ }\n});\n\nmock('addEventCallback', (callback) => {\n  callback('containerId');\n\
  });\n\nmock('sendPixel', (url) => {\n  sentUrls.push(url);\n});\n\n/* ------------\
  \ TEST UTILITY FUNCTIONS ------------ */\n\nconst getQueryParams = (url, key) =>\
  \ {\n\tconst param = url\n      .split('?')[1]\n      .split('&')\n      .map(paramString\
  \ => {\n      const keyAndVal = paramString.split('=');\n      return {key: keyAndVal[0],\
  \ val: keyAndVal[1] };\n    }).filter(param => param.key === key)[0];\n \tif (!param)\
  \ return undefined;\n\treturn param.val;\n};\n"


___NOTES___

Created on 04/12/2019, 13:17:50


