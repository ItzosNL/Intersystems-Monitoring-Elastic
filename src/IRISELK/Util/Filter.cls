Class IRISELK.Util.Filter Extends %RegisteredObject
{

ClassMethod ReplaceData(Text As %String) As %String
{
    // create regular expressions for sensitive data
    set bsnregex = ##class(%Regex.Matcher).%New("[0-9]{9}")
    set emailregex = ##class(%Regex.Matcher).%New("(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|""(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*"")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])")

    // replace sensitive data with tags   
    set bsnregex.Text = Text
    set Text = bsnregex.ReplaceAll("<BSN>")

    set emailregex.Text = Text
    set Text = emailregex.ReplaceAll("<EMAIL>")

    return Text
}

}
