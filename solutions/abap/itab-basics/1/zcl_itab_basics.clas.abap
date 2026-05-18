CLASS zcl_itab_basics DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES group TYPE c LENGTH 1.
    TYPES: BEGIN OF initial_type,
             group       TYPE group,
             number      TYPE i,
             description TYPE string,
           END OF initial_type,
           itab_data_type TYPE STANDARD TABLE OF initial_type WITH EMPTY KEY.

    METHODS fill_itab
           RETURNING
             VALUE(initial_data) TYPE itab_data_type.

    METHODS add_to_itab
           IMPORTING initial_data TYPE itab_data_type
           RETURNING
             VALUE(updated_data) TYPE itab_data_type.

    METHODS sort_itab
           IMPORTING initial_data TYPE itab_data_type
           RETURNING
             VALUE(updated_data) TYPE itab_data_type.

    METHODS search_itab
           IMPORTING initial_data TYPE itab_data_type
           RETURNING
             VALUE(result_index) TYPE i.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_itab_basics IMPLEMENTATION.

  METHOD fill_itab.
    DATA: record TYPE initial_type.
    CLEAR initial_data.


    record-group = 'A'.
    record-number = 10.
    record-description = 'Group A-2'.
    APPEND record TO initial_data.


    record-group = 'B'.
    record-number = 5.
    record-description = 'Group B'.
    APPEND record TO initial_data.

    record-group = 'A'.
    record-number = 6.
    record-description = 'Group A-1'.
    APPEND record TO initial_data.

    record-group = 'C'.
    record-number = 22.
    record-description = 'Group C-1'.
    APPEND record TO initial_data.


    record-group = 'A'.
    record-number = 13.
    record-description = 'Group A-3'.
    APPEND record TO initial_data.


    record-group = 'C'.
    record-number = 500.
    record-description = 'Group C-2'.
    APPEND record TO initial_data.
  ENDMETHOD.

  METHOD add_to_itab.
    updated_data = initial_data.
    DATA: record TYPE initial_type.
    record-group = 'A'.
    record-number = 19.
    record-description = 'Group A-4'.
    APPEND record TO updated_data. "Use updated_data, not initial_data
  ENDMETHOD.

  METHOD sort_itab.
    updated_data = initial_data.
    SORT updated_data BY group ASCENDING number DESCENDING.
  ENDMETHOD.

  METHOD search_itab.
    DATA: lv_index TYPE sy-tabix.
    LOOP AT initial_data INTO DATA(record) WHERE number = 6.
      lv_index = sy-tabix.
      EXIT.  
    ENDLOOP.

    result_index = lv_index.
  ENDMETHOD.

ENDCLASS.
