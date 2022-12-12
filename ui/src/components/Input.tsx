import styled from "styled-components";
import React from "react";

const StyledInput = styled.input`
    text-align: end;

    padding: 0px;
    margin: 0px;

    width: 240px;
    height: 50px;
    background: var(--rlm-input-color);
    border-color: ${props => props.theme.colors.border.light};
    //MY-TODO: make color prop
    backdrop-filter: blur(14px);
    /* Note: backdrop-filter has minimal browser support */

    display: block;

    font-family: var(--rlm-font);
    font-style: normal;
`;

const BottomInput = styled(StyledInput)`
    border-radius: 0px 0px 9px 9px;
    border-style: none solid solid solid;
    border-width: 0px 1px 1px 1px;

    font-weight: 500;
    font-size: 32px;
    line-height: 38px;
    /* identical to box height */

    text-align: stretch;
    letter-spacing: 0.04em;

    color: #000000;
`;

const TopInput = styled(StyledInput)`
    border-radius: 9px 9px 0px 0px;
    border-style: solid solid none solid;
    border-width: 1px 1px 0px 1px;

    font-weight: 400;
    font-size: 16px;
    line-height: 19px;
    /* identical to box height */

    text-align: stretch;
    letter-spacing: 0.22em;

    color: rgba(0, 0, 0, 0.44);
`;

export interface InputProps {
    onChange: (e:React.ChangeEvent<HTMLInputElement>) => void,
    value: string,
    prevValue: string,
}

class Input extends React.Component<InputProps> {
    render() {
        return (
            <>
                <TopInput readOnly={true} value={this.props.prevValue}/>
                <BottomInput onChange={this.props.onChange} value={this.props.value}/>
            </>
        )
    }
}

export default Input;