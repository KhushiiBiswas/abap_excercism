CLASS zcl_itab_aggregation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      group TYPE c LENGTH 1,

      BEGIN OF initial_numbers_type,
        group TYPE group,
        number TYPE i,
      END OF initial_numbers_type,

      initial_numbers TYPE STANDARD TABLE OF initial_numbers_type
        WITH EMPTY KEY,

      BEGIN OF aggregated_data_type,
        group TYPE group,
        count TYPE i,
        sum TYPE i,
        min TYPE i,
        max TYPE i,
        average TYPE f,
      END OF aggregated_data_type,

      aggregated_data TYPE STANDARD TABLE OF aggregated_data_type
        WITH EMPTY KEY.

    METHODS perform_aggregation
      IMPORTING
        initial_numbers TYPE initial_numbers
      RETURNING
        VALUE(aggregated_data) TYPE aggregated_data.

ENDCLASS.



CLASS zcl_itab_aggregation IMPLEMENTATION.

  METHOD perform_aggregation.

    DATA temp_aggregated TYPE HASHED TABLE OF aggregated_data_type
      WITH UNIQUE KEY group.

    FIELD-SYMBOLS:
      <num_data> TYPE initial_numbers_type,
      <agg_data> TYPE aggregated_data_type.

    LOOP AT initial_numbers ASSIGNING <num_data>.

      READ TABLE temp_aggregated
        ASSIGNING <agg_data>
        WITH TABLE KEY group = <num_data>-group.

      IF sy-subrc = 0.

        <agg_data>-count += 1.
        <agg_data>-sum += <num_data>-number.

        IF <num_data>-number < <agg_data>-min.
          <agg_data>-min = <num_data>-number.
        ENDIF.

        IF <num_data>-number > <agg_data>-max.
          <agg_data>-max = <num_data>-number.
        ENDIF.

      ELSE.

        INSERT VALUE aggregated_data_type(
          group   = <num_data>-group
          count   = 1
          sum     = <num_data>-number
          min     = <num_data>-number
          max     = <num_data>-number
        ) INTO TABLE temp_aggregated.

      ENDIF.

    ENDLOOP.

    LOOP AT temp_aggregated ASSIGNING <agg_data>.

      <agg_data>-average =
        CONV f( <agg_data>-sum ) / <agg_data>-count.

      APPEND <agg_data> TO aggregated_data.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.