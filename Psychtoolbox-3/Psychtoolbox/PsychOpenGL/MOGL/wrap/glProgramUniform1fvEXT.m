function glProgramUniform1fvEXT( program, location, count, value )

% glProgramUniform1fvEXT  Interface to OpenGL function glProgramUniform1fvEXT
%
% usage:  glProgramUniform1fvEXT( program, location, count, value )
%
% C function:  void glProgramUniform1fvEXT(GLuint program, GLint location, GLsizei count, const GLfloat* value)

% 30-Sep-2014 -- created (generated automatically from header files)

if nargin~=4,
    error('invalid number of arguments');
end

moglcore( 'glProgramUniform1fvEXT', program, location, count, single(value) );

return
