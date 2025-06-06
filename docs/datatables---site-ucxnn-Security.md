# Power Pages Documentation
Site Name: DataTables - site-ucxnn
Site Id: 0ec1092a-e109-4dde-88ab-eb78513c826b

## Web Roles
| Name | Description | Authenticated | Anonymous | ID |
|---|---|---|---|---|
| Administrators |  | False | False | 81e3a785-598d-454b-914b-d082b41f79c8 |
| Anonymous Users |  | False | True | d9b312d7-df4a-46cf-bfed-766b98884c6b |
| Authenticated Users |  | True | False | 35ffffef-0f54-4a69-a72d-395734a5eb52 |
| Test 2 | This role is used for other stuff. | False | False | 1b84b595-d742-f011-8779-7c1e525987b3 |
| Test1 | This role is used for things | False | False | 5c055e89-d742-f011-8779-7c1e525987b3 |

## Page Permissions
| Name | Right | Scope | Web Roles | Page Name | Rule ID |
|---|---|---|---|---|---|
| Grant Change to Administrators | 1 | 1 | Administrators | Home | 67c38668-3aa9-4311-9286-965bec60a916 |
| Grant Change to Content | 1 | 1 |  |  | df0ce3f0-af52-400c-9dca-8e506af6e665 |
| Restrict Read on Default Grid | 2 | 1 | Test1 | Default Grid | 68bd88d3-4726-6eb0-6372-08659cca05b0 |
| Restrict Read on OOTB | 2 | 1 | Test 2, Test1 | OOTB | ac0cd2a4-5773-903d-d852-0e09acf0a0d5 |

## Table Permissions
| Name | Entity | Read | Write | Create | Delete | Append | AppendTo | Scope | Web Roles | Permission ID |
|---|---|---|---|---|---|---|---|---|---|---|
| Active Accounts | account | True | False | False | False | False | False | Global | Administrators | 6aec990c-1dc3-4c9b-852c-a0461793b597 |
| Feedback | feedback | False | False | True | False | False | False | Global | Authenticated Users, Administrators, Anonymous Users | 27011573-7dc2-4a0c-93ab-50e2d982d336 |
| Table Permission 1 | account | True | True | True | True | True | True | Account | Test 2, Test1 | b7dd6b8f-11d3-4568-b682-daa747b752ae |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ Table Permissoin 1 Child | contact | True | True | True | False | False | False | Parent | Test 2, Test1 | 794d53d4-0d45-4e76-954f-da2b14b5d64a |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Table Permision1 Child1 Child | businessunit | False | False | False | True | True | True | Parent | Test 2 | 52d35377-fd26-47dd-841c-6ecb790bb178 |

## Site Settings
| Name | Value | Description | Setting ID |
|---|---|---|---|
| Authentication/LoginThrottling/IpAddressTimeoutTimeSpan | 00:10:00 | The amount of time the IP address will have to wait if Authentication/LoginThrottling/MaxInvaildAttemptsFromIPAddress occur within Authentication/LoginThrottling/MaxAttemptsTimeLimitTimeSpan amount of time. Default: 00:10:00 (10 mins) | fc2451e2-a547-423e-9ed1-c42352ed5583 |
| Authentication/LoginThrottling/MaxAttemptsTimeLimitTimeSpan | 00:03:00 | The amount of time the Authentication/LoginThrottling/MaxInvaildAttemptsFromIPAddress are to be within before the IP address has to wait Authentication/LoginThrottling/IpAddressTimeoutTimeSpan. Default: 00:03:00 (3 mins) | 4e62e15e-8a91-4bfc-81c3-6c7969a0267f |
| Authentication/LoginThrottling/MaxInvaildAttemptsFromIPAddress | 1000 | The default number of unauthenticated login attempts from an IP address before the IP address is blocked for Authentication/LoginThrottling/IpAddressTimeoutTimeSpan if the attempts occur within Authentication/LoginThrottling/MaxAttemptsTimeLimitTimeSpan amount of time. Default: 1000 | e4b3a73b-bcf8-403c-acc3-556db03d9156 |
| Authentication/LoginTrackingEnabled | False | A true or false value. If set to true, the Last Successful Login field on the portal userâ€™s contact will be updated with the date and time when they successfully signed in. | 778d25dd-f732-4450-9783-c086cf6a2c29 |
| Authentication/OpenAuth/Facebook/AppId |  |  | 1e746170-5d22-4f1b-8897-ee6142886eea |
| Authentication/OpenAuth/Facebook/AppSecret |  |  | 52534010-3895-4d9b-b5ab-368a8458ca00 |
| Authentication/OpenAuth/LinkedIn/ConsumerKey |  |  | 0e976b91-f297-40eb-8922-284d72948023 |
| Authentication/OpenAuth/LinkedIn/ConsumerSecret |  |  | 912c53e2-af51-45e3-a0e2-d2874060a8ee |
| Authentication/OpenAuth/Microsoft/ClientId |  |  | 23ed2872-1d07-4b71-a8dd-1be10fe24649 |
| Authentication/OpenAuth/Microsoft/ClientSecret |  |  | 5e5a035a-2cee-498c-a02e-3fe5b77df2a4 |
| Authentication/OpenAuth/Twitter/ConsumerKey |  |  | 532483c9-aa83-40e4-908b-ea553487c3e6 |
| Authentication/OpenAuth/Twitter/ConsumerSecret |  |  | f0431801-5f6d-45c7-8ee3-d20a205cf4ae |
| Authentication/OpenIdConnect/AzureAD/Caption | Microsoft Entra ID |  | 2c5323a2-96d2-ef11-8eea-000d3a4d79fc |
| Authentication/OpenIdConnect/AzureAD/RebrandDisclaimerEnabled | False |  | 325323a2-96d2-ef11-8eea-000d3a4d79fc |
| Authentication/Registration/AzureADLoginEnabled | True | Enables or disables Azure AD as an external identity provider. By default, it is set to true. | 53b1d669-3822-4de5-a88b-11b90fdd0094 |
| Authentication/Registration/DenyMinors | False | Denies use of the portal to minors. By default, it is set to false. | 2162d54b-0a48-4446-b1b3-8c6d08f27862 |
| Authentication/Registration/DenyMinorsWithoutParentalConsent | False | Denies use of the portal to minors without parental consent. By default, it is set to false. | 135ea8f3-61e7-4df4-b7a3-bef4cffea344 |
| Authentication/Registration/EmailConfirmationEnabled | True |  | 8865bb84-d607-4c68-b89a-b6f583e4909a |
| Authentication/Registration/Enabled | True |  | e07488dd-108c-401e-b0fc-1b7ecd0e219b |
| Authentication/Registration/ExternalLoginEnabled | True |  | 884e068a-ba51-46cd-8309-3d2979a866cf |
| Authentication/Registration/InvitationEnabled | True |  | 2857ab51-da8e-437d-a6c3-bd828f683649 |
| Authentication/Registration/LocalLoginDeprecated | False | A true or false value. If set to true, the local account will be marked as deprecated. The portal user will be required to migrate to a non-deprecated account. | 87138ea1-8731-4fb4-bab6-668f8b2545fd |
| Authentication/Registration/LocalLoginEnabled | True |  | 1243d54b-441e-4152-a988-8a2e459a291d |
| Authentication/Registration/LoginButtonAuthenticationType |  |  | 95ca0675-041e-4c8b-b495-616e0ea7a4d5 |
| Authentication/Registration/OpenRegistrationEnabled | True |  | d18a6bc5-eb99-4fb5-8077-28a875a899c6 |
| Authentication/Registration/ProfileRedirectEnabled | True | Sets whether or not the portal can redirect the user to the profile page after successful sign-in. By default, it is set to true. | 384a5ce2-87c1-4774-998a-68a04630c434 |
| Authentication/Registration/TermsAgreementEnabled | False | A true or false value. If set to true, the portal will display the terms and conditions of the site. Users must agree to the terms and conditions before they are considered authenticated and can use the site. | 1517d2dd-9432-4279-85fa-b8ae0e4c1916 |
| Authentication/Registration/TermsPublicationDate |  | A date/time value in GMT format to represent the effective date of the current published terms and conditions. If the terms agreement is enabled, portal users that have not accepted the terms after this date will be asked to accept them the next time they sign in. If the date is not provided, and the terms agreement is enabled, the terms will be presented every time portal users sign in. | 8dc86832-4bdd-49d0-ac53-76b3b9d0faa8 |
| CustomerSupport/DisplayAllUserActivitiesOnTimeline | False | Enabling this setting will show all customer activity on the portal timeline. | ca036a7a-5aba-4bc1-92fb-239096207e56 |
| Footer/OutputCache/Enabled | True | Set whether the footer web template is output cached. | 12ad5a8c-2cd8-484d-810d-7462a3ef1129 |
| Header/OutputCache/Enabled | True | Set whether the header web template is output cached. | 8ce2be4e-2f8b-4611-92f8-88b021be6069 |
| HTTP/X-Frame-Options | SAMEORIGIN |  | 184bfe49-918d-4984-8116-2ead53472f89 |
| KnowledgeManagement/DisplayNotes | False | Setting controls whether attachments will be displayed on Knowledge articles | 8e1c50a9-0fd1-4b3b-b0bf-f07a0dbc909b |
| KnowledgeManagement/NotesFilter | *WEB* | The Prefix entered here will be used to filter Notes Text, allowing you to control notes exposed on the Portal ex: *WEB* | 562d0abc-be36-469b-bec0-ccd16c8f74e7 |
| Metadata/Template-Version | 1.2304.1.0 |  | e32d9326-7d53-4512-aaca-b80bc74565a1 |
| MultiLanguage/DisplayLanguageCodeInURL | False | Site setting that determines if the language code is included in the portal URL. | 99bcd6c7-e912-4942-81a5-ce895be3497a |
| MultiLanguage/MaximumDepthToClone | 3 | Site setting that controls the depth of the webpage hierarchy thatâ€™s cloned in a newly-added supported language. Web link sets and content snippets are cloned in the newly-added language when webpages are cloned. | a05b8970-cd24-4870-ae3a-a0f1cfc0548a |
| OnlineDomains | sharepoint.com;microsoftonline.com |  | 87ee13a3-3a07-489c-838e-26c1eb812d9c |
| Profile/ForceSignUp | False |  | 30812774-606d-44c9-9954-671f66609ca4 |
| Profile/ShowMarketingOptionsPanel | True |  | 919b1db9-5a18-4247-94cf-625a964b4a87 |
| PWAFeature | {"status":"disable"} |  | cfee80d4-0a41-4287-be33-030ac1004245 |
| Search/Enabled | True |  | 16068d7a-706d-48db-a915-7d9518193191 |
| Search/EnableGenerativeAI | True |  | 365323a2-96d2-ef11-8eea-000d3a4d79fc |
| Search/FacetedView | True | Determines if faceted search is used for this portal. | c281cdc1-863f-4766-9a3a-ced0462fc6f7 |
| search/filters |  | A collection of search logical name filter options. Defining a value here will add dropdown filter options to site-wide search.<br><br>This value should be in the form of name/value pairs, with name and value separated by a colon, and pairs separated by a semicolon. For example: "Forums:adx_communityforum,adx_communityforumthread,adx_communityforumpost;Blogs:adx_blog,adx_blogpost,adx_blogpostcomment". | 0d5fd8ff-e8aa-4693-b561-a62d32cd2705 |
| Search/IndexNotesAttachments | False |  | cc219d6b-0af4-4644-bd08-be979de1ab4c |
| Search/IndexQueryName | Portal Search |  | e83e2c5d-a03c-4de4-8aca-89d8fdd77728 |
| search/query | +(@Query) _title:(@Query) _logicalname:knowledgearticle~0.9^0.3 _logicalname:annotation~0.9^0.25 _logicalname:adx_webpage~0.9^0.2 -_logicalname:adx_webfile~0.9 adx_partialurl:(@Query) _logicalname:adx_blogpost~0.9^0.1 -_logicalname:adx_communityforumthread~0.9 | Override query for site search, to apply additional weights and filters. @Query is the query text entered by a user. Lucene query syntax reference: http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html | 80780fe5-518f-46d9-9479-28da3526bfc1 |
| Search/RecordTypeFacetsEntities | Downloads:annotation,adx_webfile | Used to group a set of entities under an entry in the record type facet view. | 5cfbf8b8-520f-4846-82c7-aa4ef22e44df |
| Site/BootstrapV5Enabled | True |  | e4f415f7-9f03-41fc-b70e-ec9738942226 |
| ThemeFeature | {"status":"enable","selectedThemeId":"329a43fa-5471-4678-8330-d3a0b404e9bb","version":"V2"} |  | 7088c866-e650-4bf5-ab6c-6967915beaa1 |


