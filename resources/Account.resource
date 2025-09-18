*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    BuiltIn
Library    JSONLibrary

*** Variables ***
${BASE_URL}         https://demoqa.com
${ACCOUNT_ALIAS}    account
${BOOKSTORE_ALIAS}  bookstore

*** Keywords ***
Create Account Sessions
    Create Session    ${ACCOUNT_ALIAS}    ${BASE_URL}/Account/v1    headers={'Content-Type':'application/json'}
    Create Session    ${BOOKSTORE_ALIAS}  ${BASE_URL}/BookStore/v1  headers={'Content-Type':'application/json'}

Create User
    [Arguments]    ${username}    ${password}
    ${payload}=    Create Dictionary    userName=${username}    password=${password}
    ${resp}=       Post On Session    ${ACCOUNT_ALIAS}    /User    json=${payload}
    Should Be True    ${resp.status_code} == 201 or ${resp.status_code} == 200
    ${body}=       Set Variable    ${resp.json()}
    ${userId}=     Evaluate    ${body}.get('userID') or ${body}.get('userId')
    Run Keyword If    '${userId}' == 'None'    Fail    Could not extract userId from Create User response: ${resp.text}
    Set Suite Variable    ${USER_ID}    ${userId}

Generate Token For User
    [Arguments]    ${username}    ${password}
    ${payload}=    Create Dictionary    userName=${username}    password=${password}
    ${resp}=       Post On Session    ${ACCOUNT_ALIAS}    /GenerateToken    json=${payload}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${body}=       Set Variable    ${resp.json()}
    ${token}=      Evaluate    ${body}.get('token')
    Run Keyword If    '${token}' == 'None'    Fail    Token not returned by GenerateToken
    Set Suite Variable    ${TOKEN}    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    Update Session    ${BOOKSTORE_ALIAS}    headers=${headers}

Check User Authorized
    [Arguments]    ${username}    ${password}
    ${payload}=    Create Dictionary    userName=${username}    password=${password}
    ${resp}=       Post On Session    ${ACCOUNT_ALIAS}    /Authorized    json=${payload}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${body}=       Set Variable    ${resp.text}   # pega como string

    # Inicializa variáveis
    ${auth}=       Set Variable    ${body}
    # ${body} vem como string "true" ou "false"
    ${auth}=    Evaluate    ${body}.lower() == 'true'
    # Falha se não autorizado
    Run Keyword Unless    ${auth}    Fail    User is not authorized (response: ${body})
