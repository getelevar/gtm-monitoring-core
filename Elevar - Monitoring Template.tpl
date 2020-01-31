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
/**
 * This is required even though its not used here
 * because the tests fail without it.
*/
const log = require('logToConsole');

const VALIDATION_ERRORS = "elevar_gtm_errors";

const getEventName = (eventId, dataLayer) => {
  return dataLayer.reduce((item, curr) => {
    if (!item && curr["gtm.uniqueEventId"] === eventId) {
      return curr.event;
    }
    return item;
  }, false);
};

if (!data.debugMode) {
  // Fires after all tags for the trigger have completed
  addEventCallback(function(containerId, eventData) {
    const DATA_LAYER = copyFromWindow(data.dataLayerName ? data.dataLayerName : "dataLayer");
    const errors = copyFromWindow(VALIDATION_ERRORS);

    // This removes the validation errors from window after they have been sent
    setInWindow(VALIDATION_ERRORS, [], true);

    // Send Pixel if there are errors
    if (errors && errors.length > 0) {
      errors.forEach((errorEvent, index) => {      
        let url =
          "https://monitoring.getelevar.com/track.gif?ctid=" +
          containerId +
          "&idx=" +
          index +
          "&event_name=" +
          getEventName(errorEvent.eventId, DATA_LAYER) +
          "&error=" +
          errorEvent.error.message;

        sendPixel(url);
      });
    }
  });
}

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
- name: Get Event Name
  code: "// Call runCode to run the template's code.\nrunCode(mockData);\n\nconst\
    \ getQueryParams = (url, key) => {\n\treturn url\n      .split('?')[1]\n     \
    \ .split('&')\n      .map(paramString => {\n      const keyAndVal = paramString.split('=');\n\
    \      return {key: keyAndVal[0], val: keyAndVal[1] };\n    }).filter(param =>\
    \ param.key === key)[0].val;\n};\n\nassertApi('copyFromWindow').wasCalled();\n\
    assertThat(sentUrls.length === 2).isTrue();\nassertThat(getQueryParams('https://test.com/test_url?param=value&event_name=test_event',\
    \ 'event_name')).isEqualTo('test_event');\nassertThat(getQueryParams(sentUrls[0],\
    \ 'event_name')).isEqualTo('gtm.js');\nassertThat(getQueryParams(sentUrls[1],\
    \ 'event_name')).isEqualTo('gtm.load');"
- name: No Errors in Window
  code: |-
    elevar_gtm_errors = undefined;

    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
- name: Custom Data Layer Variable
  code: |-
    mockData = {
      customDataLayer: true,
      dataLayerName: 'customDataLayer',
    };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
setup: "const log = require('logToConsole');\n\nlet mockData = {\n  customDataLayer:\
  \ false,\n  dataLayerName: 'dataLayer',\n};\nconst sentUrls = [];\nlet dataLayer\
  \ = [\n  {\n    \"event\":\"gtm.dom\",\n    \"gtm.uniqueEventId\":3\n  },\n  {\n\
  \    \"gtm.start\":1578412516211,\n    \"event\":\"gtm.js\",\n    \"gtm.uniqueEventId\"\
  :4\n  },\n  {\n    \"gtm.start\":1578412516344,\n    \"event\":\"gtm.js\",\"gtm.uniqueEventId\"\
  :7\n  },\n  {\n    \"event\":\"gtm.load\",\"gtm.uniqueEventId\":11\n  }\n];\n\n\
  let elevar_gtm_errors = [{\n          \teventId: 7,\n            dataLayerKey: 'key',\n\
  \            error: {\n              message: 'message',\n              value: 'val',\n\
  \              condition: 'condition',\n              conditionValue: 'conditionValue'\n\
  \            }\n          }, {\n          \teventId: 11,\n            dataLayerKey:\
  \ 'key',\n            error: {\n              message: 'message',\n            \
  \  value: 'val',\n              condition: 'condition',\n              conditionValue:\
  \ 'conditionValue'\n          }}];\n\nmock('copyFromWindow', (variableName) => {\n\
  \tswitch(variableName) {\n      case 'elevar_gtm_errors':\n        return elevar_gtm_errors;\n\
  \      case mockData.dataLayerName:\n        return dataLayer;\n      default:\n\
  \        log('no object in mock window for variableName: ', variableName);\n   \
  \ }\n});\n\nmock('addEventCallback', (callback) => {\n  callback('containerId');\n\
  });\n\nmock('sendPixel', (url) => {\n  sentUrls.push(url);\n});\n"


___NOTES___

Created on 04/12/2019, 13:17:50


