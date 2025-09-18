*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    BuiltIn

*** Variables ***
${BOOKSTORE_ALIAS}  bookstore
${ACCOUNT_ALIAS}    account

*** Keywords ***
List Available Books
    ${resp}=    Get On Session    ${BOOKSTORE_ALIAS}    /Books
    Should Be Equal As Integers    ${resp.status_code}    200
    ${body}=    Set Variable    ${resp.json()}
    ${books}=   Evaluate    ${body}.get('books') or ${body}.get('Books') or ${body}
    Set Suite Variable    ${BOOKS}    ${books}
    [Return]    ${books}

Pick First Two Isbns
    ${books}=    Get Variable Value    ${BOOKS}    default=[]
    Length Should Be    ${books}    >=2
    ${isbn1}=    Evaluate    ${books}[0].get('isbn') or ${books}[0].get('ISBN') or ${books}[0]['isbn']
    ${isbn2}=    Evaluate    ${books}[1].get('isbn') or ${books}[1].get('ISBN') or ${books}[1]['isbn']
    Set Suite Variable    ${ISBN1}    ${isbn1}
    Set Suite Variable    ${ISBN2}    ${isbn2}
    [Return]    ${isbn1}    ${isbn2}

Add Books To User
    [Arguments]    ${userId}    @{isbns}
    ${collection}=    Create List
    FOR    ${isbn}    IN    @{isbns}
        ${entry}=    Create Dictionary    isbn=${isbn}
        Append To List    ${collection}    ${entry}
    END
    ${payload}=    Create Dictionary    userId=${userId}    collectionOfIsbns=${collection}
    ${resp}=    Post On Session    ${BOOKSTORE_ALIAS}    /Books    json=${payload}
    Should Be True    ${resp.status_code} == 201 or ${resp.status_code} == 200
    [Return]    ${resp}

Get User Details
    [Arguments]    ${userId}
    ${resp}=    Get On Session    ${ACCOUNT_ALIAS}    /User/${userId}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${body}=    Set Variable    ${resp.json()}
    [Return]    ${body}
