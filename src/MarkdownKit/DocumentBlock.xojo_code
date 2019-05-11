#tag Class
Protected Class DocumentBlock
Inherits MarkdownKit.Block
	#tag Method, Flags = &h21
		Private Sub AdvancePos(line As MarkdownKit.LineInfo, places As Integer, ByRef charPos As Integer, ByRef charCol As Integer, ByRef char As Text)
		  // Advances the position of the character pointer on the passed line by `places` number of places.
		  // Updates the passed ByRef parameters accordingly.
		  // If incrementing the character pointer by the specified number of places causes the pointer to 
		  // point beyond the remaining characters on the line then we set 
		  // `charPos` and `charCol` to -1 and `char` to "".
		  
		  // Sanity check.
		  If places <= 0 Then Return
		  
		  // Do the increment.
		  charPos = charPos + places
		  
		  // Bounds check.
		  If charPos > line.CharsUbound Then
		    charPos = -1
		    charCol = -1
		    char = ""
		    Return
		  End If
		  
		  // All good. Update the ByRef parameters.
		  Dim i As Integer
		  charCol = 0
		  For i = 0 To charPos
		    Select Case line.Chars(i)
		    Case &u0009 // Tab. This equates to 4 columns.
		      charCol = charCol + 4
		    Else // All other characters equate to one column.
		      charCol = charCol + 1
		    End Select
		  Next i
		  char = line.Chars(charPos)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConstructBlockStructure()
		  Dim i, limit As Integer
		  limit = Lines.Ubound
		  For i = 0 To limit
		    ProcessLine(New MarkdownKit.LineInfo(Lines(i), i), Self)
		  Next i
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(markdown As Text)
		  // Standardise the line endings in the passed Markdown to line feeds.
		  markdown = ReplaceLineEndings(markdown, MarkdownKit.kLF)
		  
		  // Replace insecure characters (spec 0.29 2.3).
		  markdown = markdown.ReplaceAll(&u0000, &uFFFD)
		  
		  // Split the Markdown into lines.
		  Lines = markdown.Split(MarkdownKit.kLF)
		  
		  // The root starts open.
		  IsOpen = True
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FindFirstNonWhitespace(line As MarkdownKit.LineInfo, ByRef startPos As Integer, ByRef charCol As Integer, ByRef char As Text)
		  // Starting at `startPos`, step through the contents of the passed line, character-by-character 
		  // until we find a non-whitespace character (NWS). 
		  // Set the passed ByRef `startPos` parameter to the zero-based index of this first NWS character.
		  // Set the passed ByRef `charCol` to the one-based column of this first NWS character.
		  // Set the passed ByRef `char` to the first NWS character.
		  // If there are no NWS on this line (searching only from `startPos` onwards) then set 
		  // `startPos` and `charCol` to -1 and `char` to "".
		  
		  // Blank line?
		  If line.Chars.Ubound < 0 Then
		    startPos = -1
		    charCol = -1
		    char = ""
		  ElseIf line.CharsUbound = 0 And line.Chars(0) = MarkdownKit.kLF Then
		    startPos = -1
		    charCol = -1
		    char = ""
		  End If
		  
		  // Check each character.
		  Dim i, column As Integer
		  Dim tmpChar As Text
		  For i = startPos To line.CharsUbound
		    tmpChar = line.Chars(i)
		    Select Case tmpChar
		    Case &u0020 // Space.
		      column = column + 1
		    Case &u0009 // Tab.
		      column = column + 4
		    Else // Non-whitespace character.
		      charCol = column + 1
		      startPos = i
		      char = tmpChar
		      Return
		    End Select
		  Next i
		  
		  // Didn't find a NWS character starting from `startPos` (inclusive) onwards.
		  startPos = -1
		  charCol = -1
		  char = ""
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ProcessLine(line As MarkdownKit.LineInfo, currentBlock As MarkdownKit.Block)
		  Dim container As MarkdownKit.Block
		  
		  // Start at the root.
		  container = Self
		  
		  // Step 1:
		  // Iterate through the open blocks and descend through the last children 
		  // down to the last open block. For each open block, check to see if this 
		  // line meets the required condition to keep the block open.
		  // In this phase we match all or just some of the open blocks but 
		  // we cannot close unmatched Blocks yet because we may have a lazy continuation line.
		  Dim allMatched As Boolean  = True
		  Dim currentChar As Text = "" // The current character on this line to handle.
		  Dim currentCharPos As Integer = 0 // Zero-based index of the current character on this line.
		  Dim currentCharCol As Integer = 1 // The one-based column that currentChar is in. Note a tab = 4 columns.
		  While container.LastChild <> Nil And container.LastChild.IsOpen
		    
		    container = container.LastChild
		    
		    // Get the first non-whitespace (NWS) character, starting from the zero-based 
		    // index `currentCharPos`. Update `currentChar`, `currentCharPos` and `CurrentCharCol`.
		    FindFirstNonWhitespace(line, currentCharPos, CurrentCharCol, currentChar)
		    
		    Select Case container.Type
		    Case MarkdownKit.BlockType.BlockQuote
		      If currentChar = ">" And currentCharCol <= 4 Then
		        // Continue this open blockquote.
		        // Advance one position along the line (past the ">" character we've just handled).
		        AdvancePos(line, 1, currentCharPos, currentCharCol, currentChar)
		      Else
		        allMatched = False
		      End If
		    End Select
		    
		    #Pragma Warning "TODO"
		    
		  Wend
		  
		  Dim lastMatchedContainer As MarkdownKit.Block = container
		  
		  // Step 2:
		  // Now that we've consumed the continuation markers for existing blocks, 
		  // we look look for new block starts (e.g: ">" for a blockquote). If we 
		  // encounter a new block start, we close any blocks unmatched in step 1 
		  // before creating the new block as a child of the last matcheed block.
		  
		  // Some container blocks can't open new blocks (e.g. code blocks)
		  While container.Type <> MarkdownKit.BlockType.FencedCode And _
		    container.Type <> MarkdownKit.BlockType.IndentedCode And _ 
		    container.Type <> MarkdownKit.BlockType.HtmlBlock
		    
		    // Get the first non-whitespace (NWS) character, starting from the zero-based 
		    // index `currentCharPos`. Update `currentChar`, `currentCharPos` and `CurrentCharCol`.
		    #Pragma Warning "TODO"
		    
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReplaceLineEndings(t As Text, what As Text) As Text
		  // Normalize the line endings first.
		  t = t.ReplaceAll(MarkdownKit.kCRLF, MarkdownKit.kLF)
		  t = t.ReplaceAll(MarkdownKit.kCR, MarkdownKit.kLF)
		  
		  // Now replace them.
		  t = t.ReplaceAll(MarkdownKit.kLF, what)
		  
		  Return t
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Lines() As Text
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsOpen"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
