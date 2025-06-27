/* Represents a single test run ---------------------------------------------------------------------------- */
DROP TABLE IF EXISTS [TestCase];

CREATE TABLE
    [TestCase] (
        --
        [Name] TEXT NOT NULL
      , [Path] TEXT NOT NULL
      , [Description] TEXT
      , [Container] TEXT NOT NULL
      , [ExecutionTime] TEXT NOT NULL UNIQUE
      , [Result] TEXT NOT NULL
  , );
