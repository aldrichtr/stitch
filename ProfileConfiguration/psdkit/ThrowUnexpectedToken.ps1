function ThrowUnexpectedToken($t1) {
	throw 'Unexpected token {0} ''{1}'' at {2}:{3}' -f $t1.Type, $t1.Content, $t1.StartLine, $t1.StartColumn
}
