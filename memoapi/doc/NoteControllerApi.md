# memoapi.api.NoteControllerApi

## Load the API package
```dart
import 'package:memoapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**create1**](NoteControllerApi.md#create1) | **POST** /memo-io-back/notes | 
[**deleteById1**](NoteControllerApi.md#deletebyid1) | **DELETE** /memo-io-back/notes/{id} | 
[**getAll1**](NoteControllerApi.md#getall1) | **GET** /memo-io-back/notes | 
[**getAllByAuthorId**](NoteControllerApi.md#getallbyauthorid) | **GET** /memo-io-back/notes/author/{id} | 
[**getById1**](NoteControllerApi.md#getbyid1) | **GET** /memo-io-back/notes/{id} | 
[**updateById1**](NoteControllerApi.md#updatebyid1) | **PUT** /memo-io-back/notes/{id} | 


# **create1**
> Object create1(noteCreateDTO)



Endpoint para adicionar uma nota

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = NoteControllerApi();
final noteCreateDTO = NoteCreateDTO(); // NoteCreateDTO | 

try {
    final result = api_instance.create1(noteCreateDTO);
    print(result);
} catch (e) {
    print('Exception when calling NoteControllerApi->create1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **noteCreateDTO** | [**NoteCreateDTO**](NoteCreateDTO.md)|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteById1**
> Object deleteById1(id)



Endpoint para deletar uma nota pelo ID

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = NoteControllerApi();
final id = 789; // int | 

try {
    final result = api_instance.deleteById1(id);
    print(result);
} catch (e) {
    print('Exception when calling NoteControllerApi->deleteById1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAll1**
> Object getAll1()



Endpoint para listar todas as notas

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = NoteControllerApi();

try {
    final result = api_instance.getAll1();
    print(result);
} catch (e) {
    print('Exception when calling NoteControllerApi->getAll1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAllByAuthorId**
> Object getAllByAuthorId(id)



Endpoint para listar todas as notas de um autor pelo ID

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = NoteControllerApi();
final id = 789; // int | 

try {
    final result = api_instance.getAllByAuthorId(id);
    print(result);
} catch (e) {
    print('Exception when calling NoteControllerApi->getAllByAuthorId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getById1**
> Object getById1(id)



Endpoint para exibir os dados de uma nota pelo ID

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = NoteControllerApi();
final id = 789; // int | 

try {
    final result = api_instance.getById1(id);
    print(result);
} catch (e) {
    print('Exception when calling NoteControllerApi->getById1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateById1**
> Object updateById1(id, noteUpdateDTO)



Endpoint para atualizar os dados de uma nota pelo ID

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = NoteControllerApi();
final id = 789; // int | 
final noteUpdateDTO = NoteUpdateDTO(); // NoteUpdateDTO | 

try {
    final result = api_instance.updateById1(id, noteUpdateDTO);
    print(result);
} catch (e) {
    print('Exception when calling NoteControllerApi->updateById1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **noteUpdateDTO** | [**NoteUpdateDTO**](NoteUpdateDTO.md)|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

