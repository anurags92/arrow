# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

class TestListArray < Test::Unit::TestCase
  include Helper::Buildable

  def test_new
    value_offsets = Arrow::Buffer.new([0, 2, 5, 5].pack("l*"))
    data = Arrow::Buffer.new([1, 2, 3, 4, 5].pack("c*"))
    values = Arrow::Int8Array.new(5, data, nil, 0)
    assert_equal(build_list_array(Arrow::Int8ArrayBuilder,
                                  [[1, 2], [3, 4, 5], nil]),
                 Arrow::ListArray.new(3,
                                      value_offsets,
                                      values,
                                      Arrow::Buffer.new([0b011].pack("C*")),
                                      -1))
  end

  def test_value
    builder = Arrow::ListArrayBuilder.new(Arrow::Int8ArrayBuilder.new)
    value_builder = builder.value_builder

    builder.append
    value_builder.append(-29)
    value_builder.append(29)

    builder.append
    value_builder.append(-1)
    value_builder.append(0)
    value_builder.append(1)

    array = builder.finish
    value = array.get_value(1)
    assert_equal([-1, 0, 1],
                 value.length.times.collect {|i| value.get_value(i)})
  end

  def test_value_type
    builder = Arrow::ListArrayBuilder.new(Arrow::Int8ArrayBuilder.new)
    array = builder.finish
    assert_equal(Arrow::Int8DataType.new, array.value_type)
  end
end
