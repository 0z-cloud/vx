from numbers import Number

def parse_response(value_columns, response, metric=[], labels={}):
    result = []

    for row in response:
      result_labels = {column: (str(row[column]),) for column in row if column not in value_columns}
      final_labels = labels.copy()
      final_labels.update(result_labels)
      for value_column in value_columns:
        value = row[value_column]
        if isinstance(value, Number):
          result.append((metric + [value_column], final_labels, value))

    return result
