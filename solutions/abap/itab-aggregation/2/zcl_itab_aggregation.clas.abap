CLASS zcl_itab_aggregation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      group TYPE c LENGTH 1,
      BEGIN OF initial_numbers_type,
        group  TYPE group,
        number TYPE i,
      END OF initial_numbers_type,
      initial_numbers TYPE STANDARD TABLE OF initial_numbers_type WITH EMPTY KEY,

      BEGIN OF aggregated_data_type,
        group   TYPE group,
        count   TYPE i,
        sum     TYPE i,
        min     TYPE i,
        max     TYPE i,
        average TYPE f,
      END OF aggregated_data_type,
      aggregated_data TYPE STANDARD TABLE OF aggregated_data_type WITH EMPTY KEY.

    TYPES:
      ty_initial        TYPE initial_numbers_type,
      tt_initial        TYPE initial_numbers,
      ty_aggregated     TYPE aggregated_data_type,
      tt_aggregated     TYPE aggregated_data.

    METHODS perform_aggregation
      IMPORTING
        initial_numbers TYPE initial_numbers
      RETURNING
        VALUE(aggregated_data) TYPE aggregated_data.

ENDCLASS.

CLASS zcl_itab_aggregation IMPLEMENTATION.

  METHOD perform_aggregation.

    DATA lt_agg_by_group TYPE HASHED TABLE OF aggregated_data_type
      WITH UNIQUE KEY group.

    FIELD-SYMBOLS:
      <ls_num> TYPE initial_numbers_type,
      <ls_agg> TYPE aggregated_data_type.

    " Aggregate per group using a hashed table for O(1) access
    LOOP AT initial_numbers ASSIGNING <ls_num>.

      READ TABLE lt_agg_by_group ASSIGNING <ls_agg>
        WITH TABLE KEY group = <ls_num>-group.

      IF sy-subrc <> 0.
        " First record for this group -> initialize aggregation line
        INSERT VALUE aggregated_data_type(
          group = <ls_num>-group
          count = 0
          sum   = 0
          min   = <ls_num>-number
          max   = <ls_num>-number
        ) INTO TABLE lt_agg_by_group.

        READ TABLE lt_agg_by_group ASSIGNING <ls_agg>
          WITH TABLE KEY group = <ls_num>-group.
      ENDIF.

      " Update metrics
      <ls_agg>-count = <ls_agg>-count + 1.
      <ls_agg>-sum   = <ls_agg>-sum   + <ls_num>-number.

      IF <ls_num>-number < <ls_agg>-min.
        <ls_agg>-min = <ls_num>-number.
      ELSEIF <ls_num>-number > <ls_agg>-max.
        <ls_agg>-max = <ls_num>-number.
      ENDIF.

    ENDLOOP.

    " Finalize: calculate average + return as standard table
    LOOP AT lt_agg_by_group ASSIGNING <ls_agg>.
      <ls_agg>-average = CONV f( <ls_agg>-sum ) / <ls_agg>-count.
      APPEND <ls_agg> TO aggregated_data.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.