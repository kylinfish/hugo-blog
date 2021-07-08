---
title: "Pytest Example and Cheat Sheet 小抄"
description: "Pytest 常用情境小抄: fixture, mark.parametrize, raises(Exception), capsys.readouterr(), side_effect, mocker object assertion"
date: "2020-06-11T16:55:04+08:00"
draft: false
tags: [ "python", "pytest" ]
categories: ["技術"]

featuredImage: "/img/post/python.jpg"
images: ["/img/post/python.jpg"]

---

Pytest 常用的情境小抄
<!--more-->

## `pytest.fixture`

### Scenario:

- Set up OS environment for every test cases.
- Set up Git tag to running environment.
- **setup** / **teardown**

`pytest.fixture(scope="XXX")`

- Available scope:
    - function *(default)*
    - class
    - module
    - session

{{< highlight python >}}
@pytest.fixture(scope="function", autospec=True)
def set_env():
	os.environ["ENV"] = "dev"
	os.environ["OWNER"] = "frs"
	os.environ["SYS"] = "trx"
	os.environ["COMP"] = "xshield"
{{</ highlight >}}

ref. [pytest中的fixture](https://note.qidong.name/2018/01/pytest-fixture/)

## `pytest.mark.parametrize`

### Scenario

- Multiple sets of arguments and expected results.
- like PHPUnit - @dataProvider annotation

{{< highlight python >}}
@pytest.mark.parametrize("test_input, expected", [
    ([1, 1], 2),
    ([2, 2], 4),
    ([0, 1], 1),
])
def test_add(test_input, expected):
    assert expected == add(test_input[0], test_input[1])
{{</ highlight >}}

ref. [Parametrizing fixtures and test functions - pytest documentation](https://docs.pytest.org/en/latest/parametrize.html#pytest-mark-parametrize)

## `pytest.raises(Exception)`

### Scenario

- Catch the exception from function error running
- Verify the exception message

{{< highlight python >}}
def test_zero_division():
    with pytest.raises(ZeroDivisionError): # Catch ZeroDivisionError Exception
        1 / 0   # Expected error happen here!!
{{</ highlight >}}

{{< highlight python >}}
def test_recursion_depth():
    with pytest.raises(BaseException) as excinfo:
				some_func_raise_exception()   # Expected error happen here!!

    assert "Exception Message Which You Want To Assert" in str(excinfo.value)
{{</ highlight >}}

[The writing and reporting of assertions in tests - pytest documentation](https://docs.pytest.org/en/latest/assert.html#assertions-about-expected-exceptions)

## `capsys.readouterr()`

### Scenario

- Capture of the stdout/stderr output


{{< highlight python >}}
def test_output(capsys):  # or use "capfd" for fd-level
    print("hello")
    sys.stderr.write("world\n")

    captured = capsys.readouterr()
    assert captured.out == "hello\n"      # standard output
    assert captured.err == "world\n"      # standard error
{{</ highlight >}}

## `side_effect`

### Scenario

- Override calls
- Patch method which can return different value depends on input argument.
- Raise an exception when calling the Mock

{{< highlight python >}}
# custom function
def get_foo_bar(key):
	return "foo" if key == "foo" else "bar"

def test_with_diff_ssm_value(mocker):
      event = {"foo": "bar", "ssm_input": "foo"}

			# assign the side_effect to return_value
      m_ssm = mocker.patch("SSMParameterStore", autospec=True)
      m_ssm.return_value.get_param.side_effect = get_foo_bar

			# mock method will return value by custom function
      actual = lambda_handler(event, None)

      expect = {"foo": "bar", "ssm_value": "foo"}

      assert actual == expect
{{</ highlight >}}


{{< highlight python >}}
def test_unexpected_error(mocker):
      m_obj = mocker.patch("aws.emr.get_step_status", side_effect=TypeError)

      event = {"pattern_label": {"emr": {"id": "j-3FVHTO6QGW09Q"}}}

      with pytest.raises(SomeException):
          lambda_handler(event, None)

      assert m_obj.call_count == 1
{{</ highlight >}}

----

## Mocker Object Assertions
Mocker Object Assertions you may need

### Mocker Property

- call_once
- call_count
- call_args

{{< highlight python >}}
assert mocker_obj.call_once
assert mocker_obj.call_count == 3
assert mocker_obj.call_args == ["dev-xshield", 'TlshLabel', "day_fn_count"]
{{</ highlight >}}

### Mocker method

- assert_called_once()
- assert_not_called()
- assert_called_once_with("args", "input")

{{< highlight python >}}
mocker_obj.assert_called_once()
mocker_obj.assert_not_called()
mocker_obj.assert_called_once_with("args", "input")
{{</ highlight >}}