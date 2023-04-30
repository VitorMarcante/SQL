  USE master;
	ALTER DATABASE Universidade SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	GO
	DROP DATABASE Universidade;
	GO
	USE master;
	CREATE DATABASE Universidade;
	GO
	USE Universidade;
	GO
	CREATE TABLE ALUNOS
	(
		MATRICULA INT NOT NULL IDENTITY
			CONSTRAINT PK_ALUNO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE CURSOS
	(
		CURSO CHAR(3) NOT NULL
			CONSTRAINT PK_CURSO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE PROFESSOR
	(
		PROFESSOR INT IDENTITY NOT NULL
			CONSTRAINT PK_PROFESSOR PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE MATERIAS
	(
		SIGLA CHAR(4) NOT NULL,
		NOME VARCHAR(50) NOT NULL,
		CARGAHORARIA INT NOT NULL,
		CURSO CHAR(3) NOT NULL,
		PROFESSOR INT NOT NULL
			CONSTRAINT PK_MATERIA
			PRIMARY KEY (
							SIGLA,
							CURSO,
							PROFESSOR
						)
			CONSTRAINT FK_CURSO
			FOREIGN KEY (CURSO) REFERENCES CURSOS (CURSO),
		CONSTRAINT FK_PROFESSOR
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
    CREATE TABLE MATRICULA
	(
		MATRICULA INT,
		CURSO CHAR(3),
		MATERIA CHAR(4),
		PROFESSOR INT,
		PERLETIVO INT,
		N1 FLOAT,
		N2 FLOAT,
		N3 FLOAT,
		N4 FLOAT,
		TOTALPONTOS FLOAT,
		MEDIA FLOAT,
		F1 INT,
		F2 INT,
		F3 INT,
		F4 INT,
		TOTALFALTAS INT,
		PERCFREQ FLOAT,
		RESULTADO VARCHAR(20),
        NOTAEXAME FLOAT,
        MEDIAFINAL FLOAT,
        RESULTADOFINAL VARCHAR(20)
			CONSTRAINT PK_MATRICULA
			PRIMARY KEY (
							MATRICULA,
							CURSO,
							MATERIA,
							PROFESSOR,
							PERLETIVO
						),
		CONSTRAINT FK_ALUNOS_MATRICULA
			FOREIGN KEY (MATRICULA)
			REFERENCES ALUNOS (MATRICULA),
		CONSTRAINT FK_CURSOS_MATRICULA
			FOREIGN KEY (CURSO)
			REFERENCES CURSOS (CURSO),
		--CONSTRAINT FK_MATERIAS FOREIGN KEY (MATERIA) REFERENCES MATERIAS (SIGLA),
		CONSTRAINT FK_PROFESSOR_MATRICULA
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO

    CREATE PROCEDURE CadastrarAluno 
        @Nome VARCHAR(50)
    AS
    BEGIN
        INSERT INTO ALUNOS (NOME)
        VALUES (@Nome);
    END
    GO

    CREATE PROCEDURE CadastrarProfessor 
        @Nome VARCHAR(50)
    AS
    BEGIN
        INSERT INTO PROFESSOR (NOME)
        VALUES (@Nome);
    END
    GO
        CREATE PROCEDURE CadastrarCurso 
        @Curso CHAR(3),
        @Nome VARCHAR(50)
    AS
    BEGIN
        INSERT INTO CURSOS (CURSO, NOME)
        VALUES (@Curso, @Nome);
    END
    GO

CREATE PROCEDURE CadastrarMateria 
    @Sigla CHAR(4),
    @Nome VARCHAR(50),
    @CargaHoraria INT,
    @Curso CHAR(3),
    @Professor INT
AS
BEGIN
    INSERT INTO MATERIAS (SIGLA, NOME, CARGAHORARIA, CURSO, PROFESSOR)
    VALUES (@Sigla, @Nome, @CargaHoraria, @Curso, @Professor);
    
    -- Add foreign key referente a tabela MATRICULA
    ALTER TABLE MATRICULA
    ADD CONSTRAINT FK_MATERIA_MATRICULA
    FOREIGN KEY (MATERIA, CURSO, PROFESSOR)
    REFERENCES MATERIAS (SIGLA, CURSO, PROFESSOR);
END 
GO

CREATE PROCEDURE PreencherMatricula
    @Matricula INT,
    @Curso CHAR(3),
    @Materia CHAR(4),
    @Professor INT,
    @PerLetivo INT,
    @N1 FLOAT,
    @N2 FLOAT,
    @N3 FLOAT,
    @N4 FLOAT,
    @F1 INT,
    @F2 INT,
    @F3 INT,
    @F4 INT,
    @Nexame FLOAT
AS
    DECLARE @TotalPontos FLOAT, @Media FLOAT, @TotalFaltas INT, @PercFreq FLOAT, @MediaExame FLOAT, @Resultado VARCHAR(20),@ResultadoFinal VARCHAR(20);
BEGIN
    BEGIN
    -- Calcula o total de pontos e a média
    SET @TotalPontos = @N1 + @N2 + @N3 + @N4;
    SET @Media = @TotalPontos / 4.0;

    -- Calcula o total de faltas e a percentagem de frequência
    SET @TotalFaltas = @F1 + @F2 + @F3 + @F4;
    SET @PercFreq = (1 - (@TotalFaltas / 80.0)) * 100.0;

    -- Calcula a media pós exame
    SET @MediaExame = (@Media + @Nexame)/2;
    IF @Nexame = NULL
        SET @MediaExame =NULL

    -- Determina o resultado
    IF @Media >= 6.0 AND @PercFreq >= 75.0
        SET @Resultado = 'APROVADO';
    ELSE IF @Media >= 3.0 AND @PercFreq >= 75.0
        SET @Resultado = 'EXAME';
    ELSE
        SET @Resultado = 'REPROVADO';
    END
    BEGIN
    IF @Resultado = 'APROVADO'
        SET @ResultadoFinal = 'APROVADO'
    ELSE IF @Resultado = 'REPROVADO'
        SET @ResultadoFinal = 'REPROVADO'
    ELSE IF @Resultado = 'EXAME' AND @MediaExame >= 6.0 
		SET @ResultadoFinal = 'APROVADO';
    ELSE IF @Resultado = 'EXAME' AND @MediaExame < 6.0
        SET @ResultadoFinal = 'REPROVADO'
    ELSE 
        SET @ResultadoFinal = NULL;
    END
    -- Insere os dados na tabela MATRICULA
    INSERT INTO MATRICULA (MATRICULA, CURSO, MATERIA, PROFESSOR, PERLETIVO, N1, N2, N3, N4, TOTALPONTOS, MEDIA, F1, F2, F3, F4, TOTALFALTAS, PERCFREQ, RESULTADO,MEDIAFINAL,NOTAEXAME,RESULTADOFINAL)
    VALUES (@Matricula, @Curso, @Materia, @Professor, @PerLetivo, @N1, @N2, @N3, @N4, @TotalPontos, @Media, @F1, @F2, @F3, @F4, @TotalFaltas, @PercFreq, @Resultado,@MediaExame,@Nexame,@ResultadoFinal);
    
    UPDATE MATRICULA SET N1 = @N1 WHERE MATRICULA = @MATRICULA
END
GO

--CREATE PROCEDURE Exame
--@Nexame FLOAT,
--@Nnova FLOAT
--AS
--BEGIN
--    BEGIN
--    IF @Nexame = NULL
--        SET @Nexame = @Nnova
--    END
--    UPDATE MATRICULA WHERE RESULTADO = 'EXAME'
 --   VALUES()
--

--GO

EXEC CadastrarAluno 'Pedro';
EXEC CadastrarAluno 'Gabriela';
EXEC CadastrarAluno 'Vitor';

GO

EXEC CadastrarCurso 'SIS', 'Sistemas';
EXEC CadastrarCurso 'ENG', 'ENGENHARIA';
GO
EXEC CadastrarProfessor 'Dornel';
EXEC CadastrarProfessor 'Walter';
EXEC CadastrarProfessor 'Alexandre';

GO

EXEC CadastrarMateria 'BDAS', 'Banco de Dados (Sistemas)', 144, 'SIS', 1;
GO
EXEC CadastrarMateria 'ALGS', 'Algoritimos (Sistemas)', 167, 'SIS', 2;
GO
EXEC CadastrarMateria 'ENRS', 'Engenharia de Requisitos (Sistemas)', 144, 'SIS', 3;
GO
EXEC CadastrarMateria 'BDAE', 'Banco de Dados (Engenharia)', 144, 'ENG', 1;
GO
EXEC CadastrarMateria 'ALGE', 'Algoritimos (Engenharia)', 167, 'ENG', 2;
GO
EXEC CadastrarMateria 'ENRE', 'Engenharia de Requisitos (Engenharia)', 144, 'ENG', 3;

GO
EXEC PreencherMatricula 1, 'SIS', 'BDAS', 1, 2023, 3.0, 4.5, 6.0,4.0, 3, 2, 0, 5,10.0; --EM EXAME E FREQUENCIA SUFICIENTE
EXEC PreencherMatricula 2, 'ENG', 'BDAE', 1, 2023, 7.0, 8.5, 9.0, 6.5, 10, 4, 2, 5,NULL; --NOTA ACIMA DA MÉDIA  E REPROVOU POR FALTA
EXEC PreencherMatricula 3, 'ENG', 'BDAE', 1, 2023, 10.0, 10.0, 10.0, 10.0, 1, 2, 0, 5,NULL; --NOTA ACIMA DA MÉDIA E FREQUÊNCIA SUFICIENTE
EXEC PreencherMatricula 1, 'SIS', 'ALGS', 2, 2023, 2.0, 1.5, 1.0, 3.5, 0, 2, 0, 5,NULL; --REPROVOU DIRETO E FREQUENCIA SUFICIENTE
EXEC PreencherMatricula 2, 'ENG', 'ALGE', 2, 2023, 4.0, 1.5, 2.0, 1.5, 9, 8, 0, 5,NULL; --REPROVOU DIRETO E POR FALTA
EXEC PreencherMatricula 3, 'ENG', 'ALGE', 2, 2023, 10.0, 10.0, 10.0, 10.0, 4, 2, 0, 2,NULL; --NOTA ACIMA DA MÉDIA E FREQUÊNCIA SUFICIENTE
EXEC PreencherMatricula 1, 'SIS', 'ENRS', 3, 2023, 3.0, 3.5, 3.0, 3.5, 15, 2, 4, 4,NULL; --EM EXAME E REPROVADO POR FALTA
EXEC PreencherMatricula 2, 'ENG', 'ENRE', 3, 2023, 4.0, 3.5, 2.0, 5.5, 5, 2, 0, 3,3; --EM EXAME E FREQUENCIA SUFICIENTE
EXEC PreencherMatricula 3, 'ENG', 'ENRE', 3, 2023,10.0, 10.0, 10.0, 10.0, 1, 3, 2, 5,NULL;--NOTA ACIMA DA MÉDIA E FREQUÊNCIA SUFICIENTE




SELECT * FROM ALUNOS
SELECT * FROM CURSOS
SELECT * FROM PROFESSOR
SELECT * FROM MATERIAS
SELECT * FROM MATRICULA
