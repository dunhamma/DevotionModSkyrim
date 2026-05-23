export class AuthoringError extends Error {
  constructor(message, details = {}) {
    super(message);
    this.name = "AuthoringError";
    this.details = details;
  }
}

export class ValidationError extends AuthoringError {
  constructor(message, details = {}) {
    super(message, details);
    this.name = "ValidationError";
  }
}

export class UnsupportedFormatError extends AuthoringError {
  constructor(message, details = {}) {
    super(message, details);
    this.name = "UnsupportedFormatError";
  }
}
